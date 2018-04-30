+++
date = "2018-04-30T15:00:00+09:00"
title = "Don't work hugo autorebuild with dinghy"
tags = ["hugo", "dinghy", "fsevent", "inotify", "go", "ruby"]
categories = ["programming"]
+++

host側のvolumeをmountしているのだが、その変更をwatcherが補足しない = LiveReloadが動かないのはかなり辛い。

そのため、hugoとdinghyのコードを追う。

## そもそもdinghyがmountしたhostのfseventを伝搬できているのか？

dinghyは `fsevent` を vmに伝搬しているはず。
そのため、 `inotify-tools` を使ってどのようなeventとして伝搬されているのか確認する。

```sh
$ docker run -it --rm -v $PWD:/app debian:latest sh

% apt-get update && apt-get install -y inotify-tools
% cd /app
% inotifywait -rme modify,attrib,move,close_write,create,delete,delete_self .
Setting up watches.  Beware: since -r was given, this may take a while!
Watches established.

# fileをcontainer内で作成するとcreateのeventを補足する
$ docker exec 2a5e08389e9b touch /app/foo.md

./ CREATE foo.md
./ ATTRIB foo.md
./ CLOSE_WRITE,CLOSE foo.md
./ ATTRIB foo.md

# fileをhost側で作成するとATTRIBしか補足しない
$ touch bar.md
$ echo "foo" > ./bar.md

./ ATTRIB bar.md
./ ATTRIB bar.md
```

host側の変更が `attrib` にしかならないのなぜ？

## dinghyではどのようにfseventをvmに伝搬させているか？

rb-fseventでfileのeventとtimeを送るようにしている。

```rb
# https://github.com/codekitchen/fsevents_to_vm/blob/master/lib/fsevents_to_vm/watch.rb

    def run
      @fs.watch(@listen_dirs, file_events: true) do |files|
        files.each do |file|
          event = build_event(file)
          yield event if event
        end
      end
      @fs.run
    end

    private

    def build_event(filepath)
      mtime = Event.format_time(File.stat(filepath).mtime)
      Event.new(filepath, mtime, Time.now)
    rescue Errno::ENOENT
      # TODO: handling delete events is tricky due to race conditions with rapid
      # delete/create.
      nil
    rescue Errno::ENOTDIR
      # dir structure changed
      nil
    end
```

取得されたイベントはtouch commandを用いてfileの編集時刻を更新する。これによってcontainer内でeventを発火させている。

```rb
# https://github.com/codekitchen/fsevents_to_vm/blob/master/lib/fsevents_to_vm/ssh_emit.rb

    def event(event)
      ssh.exec!("touch -m -c -t #{event.mtime} #{Shellwords.escape event.path}".force_encoding(Encoding::BINARY))
    rescue IOError, SystemCallError, Net::SSH::Exception => e
      $stderr.puts "Error sending event: #{e.class}: #{e}"
      $stderr.puts "\t#{e.backtrace.join("\n\t")}"
      disconnect!
    end
```

これだとATTRIBになってしまうのは致し方がない。

## hugoでのattrib eventの取扱い

hugoでは [fsnotify](https://github.com/fsnotify/fsnotify) を利用してfileのeventを取得している。
そのため、fsnotify側のattribの取扱いを追う。

```go
# https://github.com/fsnotify/fsnotify/blob/master/inotify.go

# `Chmod` Operatorとしている。
    if mask&unix.IN_ATTRIB == unix.IN_ATTRIB {
        e.Op |= Chmod
    }
```

`Chmod` Operatorとしている。
そして、hugo serverは `Chmod` eventが発生した時、 `fullRebuild` をしないような処理となっている。


```
# https://github.com/gohugoio/hugo/blob/master/commands/hugo.go

					// Write and rename operations are often followed by CHMOD.
					// There may be valid use cases for rebuilding the site on CHMOD,
					// but that will require more complex logic than this simple conditional.
					// On OS X this seems to be related to Spotlight, see:
					// https://github.com/go-fsnotify/fsnotify/issues/15
					// A workaround is to put your site(s) on the Spotlight exception list,
					// but that may be a little mysterious for most end users.
					// So, for now, we skip reload on CHMOD.
					// We do have to check for WRITE though. On slower laptops a Chmod
					// could be aggregated with other important events, and we still want
					// to rebuild on those
					if ev.Op&(fsnotify.Chmod|fsnotify.Write|fsnotify.Create) == fsnotify.Chmod {
						continue
					}
```

## どうする？

rb-fsevent側でcreate,modifyなどのeventが取得できるか試したが、そのようなmeta dataが上手く取得したり、伝搬する方法も思いつかなかった。(やり方が悪い？）

attrib以外のeventとして渡すことができないとなると、hugoにPRを出すことに成るが、そもそも上記のように問題があるからskipしている。
そうすると

1. brewで提供されているんだからmacのlocalでやればいいじゃん
1. docker-for-mac使えば伝搬されるよ？
  - https://docs.docker.com/docker-for-mac/osxfs/#file-system-events

localでやれば良いよね。


