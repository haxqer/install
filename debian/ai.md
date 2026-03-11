# ai 工具使用方式

## codex

参考： https://github.com/haxqer/install/blob/master/debian/install-codex.sh

## openclaw

安装过程中可以先不管模型配置，安装完成后，直接去编辑配置文件 ~/.openclaw/openclaw.json
其中模型配置部分 models 直接使用这个，其中 sk-xxxx 替换成你的密钥

```json
"models": {
      "providers": {
        "hax": {
          "baseUrl": "https://aiapiv2.xgit.fun/v1",
          "apiKey": "你的秘钥sk-xxxx",
          "auth": "api-key",
          "api": "openai-responses",
          "authHeader": true,
          "models": [
            {
              "id": "gpt-5.4",
              "name": "GPT-5.4",
              "reasoning": true,
              "input": [
                "text",
                "image"
              ]
            }
          ],
          "headers": {
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) OpenClaw/2026.2.14",
            "Accept": "application/json"
          }
        }
      }
    },
    "agents": {
      "defaults": {
        "model": {
          "primary": "hax/gpt-5.4"
        },
        "models": {
          "hax/gpt-5.4": {
            "alias": "GPT 5.4"
          }
        },
        "workspace": "/root/.openclaw/workspace",
        "compaction": {
          "mode": "safeguard"
        },
        "maxConcurrent": 4,
        "subagents": {
          "maxConcurrent": 8
        }
      }
    }
```
