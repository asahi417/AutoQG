# ACL Demo Setup

- Launch Inference Sever (On GPU Server)
```bash
git clone https://github.com/asahi417/lm-question-generation
cd lm-question-generation

# first endpoint
uvicorn app_local:app --host 0.0.0.0 --port 8088

# second endpoint
uvicorn app_local:app --host 0.0.0.0 --port 8888
```

- Launch UI (On Local Machine)
```
# first endpoint
flutter run -d chrome -t lib/main_1.dart --web-port 8088

# second endpoint
flutter run -d chrome -t lib/main_2.dart --web-port 8888
```