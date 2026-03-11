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

## opencode

`~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "hax": {
      "npm": "@ai-sdk/openai",
      "name": "hax",
      "options": {
        "baseURL": "https://aiapiv2.xgit.fun/v1"
      },
      "models": {
        "gpt-5.4": {
          "name": "GPT-5.4",
          "thinking": true,
          "modalities": {
            "input": ["text", "image", "pdf"],
            "output": ["text"]
          },
          "limit": {
            "context": 400000,
            "output": 128000
          },
          "options": {
            "store": false,
            "reasoningEffort": "xhigh",
            "textVerbosity": "high",
            "reasoningSummary": "auto",
            "include": ["reasoning.encrypted_content"]
          }
        },
        "gpt-5.3-codex": {
          "name": "GPT-5.3 Codex",
          "options": {
            "include": ["reasoning.encrypted_content"],
            "store": false
          }
        }
      }
    }
  }
}
```

`~/.local/share/opencode/auth.json`:

```json
{
  "供应商名称": {
    "type": "api",
    "key": "你的API密钥"
  }
}
```
