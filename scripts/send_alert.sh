alerts='[
  {
    "labels": {
       "alertname": "downtime",
       "serverity": "cretical",
       "instance": "example1"
     },
     "annotations": {
        "info": "information",
        "summary": "please check the instance example1",
        "runbook": "the following link http://test-url should be clickable"
      }
  }
]'

curl -XPOST -d"$alerts" http://localhost:9093/api/v1/alerts
