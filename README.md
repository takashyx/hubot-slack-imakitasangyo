# hubot-slack-imakitasangyo
A imakitasangyo alert script for hubot-slack

## Description
Summerize recent posts in the channel when someone posts "今北産業" on Slack.

![](https://github.com/takashyx/hubot-slack-imakitasangyo/wiki/images/preview.png)

## Requirements

- recruit-tech/summpy
https://github.com/recruit-tech/summpy

You need to host this API by yourself.

## Installation

- Go to your hubot-slack directory and run

```bash
npm install hubot-slack-imakitasangyo --save
```

to add `hubot-slack-imakitasangyo` to `package.json` of your hubot-slack

- Add `hubot-slack-imakitasangyo` to `external-scripts.json` of your hubot-slack


```bash
$ cat external-scripts.json
[
  ... ,
  "hubot-slack-imakitasangyo",
  ...
]
```

### Required parameters

Envs
```bash
export HUBOT_SLACK_TOKEN=[SLACK TOKEN. ex: "xoxp-hogehogehogehoge"]
export HUBOT_IMAKITASANGYO_BOT_USER_ID=[Bot's user ID. ex: "U021A3SA3"]
export HUBOT_IMAKITASANGYO_SUMMPY_API_URL=[Summpy API URL. ex: "http://127.0.0.1:9000/summarize"]
export HUBOT_IMAKITASANGYO_SOURCE_LINES=[Number of lines to be summerized. ex: "30"]
```

## Special thanks
This script uses Recruit Tech's API.
