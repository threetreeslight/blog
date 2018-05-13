+++
date = "2014-09-10T10:21:53+00:00"
draft = false
tags = ["ssh", "percol"]
title = "sshをEC2のタグからpercol経由でよしなにする"
+++


掲題の通り辛くなってきたので、雑ですが書きました。

## require

- AWS CLI
- percol
- zsh

## Install AWS Cli

http://docs.aws.amazon.com/cli/latest/userguide/installing.html

```bash
$ sudo pip install awscli
```

Locale周りの設定していなかったのでlocal設定をする

```bash
$ vim ~/.zshrc
export LC_ALL=ja_JP.UTF-8
```

configure


```bash
# Configuration
$ aws configure
AWS Access Key ID: YOUR_AWS_ACCSS_KEY_ID
AWS Secret Access Key: YOUR_SECRET_ACCSS_KEY
Default region name [us-west-2]: いんすたんすのあるりーじょん
Default output format [None]: text
```

## ssh-login with ec2 via percol

```bash
# ec2-ip
function ec2-ip() {
  instances | percol | awk '{ print $1 }'
}

function instances() {
  instances=( $(aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value[],PublicIpAddress]' \
    --output text) )

  for i in `seq 1 ${#instances[@]}`; do
    if [ `expr $i % 2` -eq 0 ]; then
      echo ${instances[$i-1]} ${instances[$i]}
    fi
  done
}

# ec2-ssh
function ec2-ssh() {
  ssh webadmin@`ec2-ip` -p2222 -i ~/.ssh/id_rsa
}
```
