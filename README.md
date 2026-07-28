# 개발 워크스테이션 구축 과제

## 1) 프로젝트 개요

터미널, Docker(OrbStack), Git/GitHub을 직접 세팅하고 다뤄보며, 어떤 컴퓨터에서든 동일하게 실행·배포·디버깅할 수 있는 개발 환경 구성 원리를 익히는 것을 목표로 한 과제입니다.

- 터미널 기본 조작 및 파일 권한 실습
- Docker(OrbStack) 설치 및 기본 운영 명령 수행
- Dockerfile 기반 커스텀 웹서버 이미지 제작
- 포트 매핑을 통한 컨테이너 접속
- 바인드 마운트 및 볼륨을 통한 데이터 반영/영속성 검증
- Git 설정 및 GitHub · VSCode 연동

## 2) 실행 환경

| 항목 | 내용 |
| --- | --- |
| OS | macOS |
| Shell | bash (`bash-3.2`) |
| Docker | 29.4.0 (OrbStack 엔진 기반, `Context: orbstack`) |
| Git | git version 2.50.1 (Apple Git-155) |

## 3) 수행 체크리스트

- [x]  터미널 기본 조작 (이동/생성/복사/이름변경/삭제)
- [x]  파일 1개 · 디렉토리 1개 권한 변경 실습
- [x]  Docker(OrbStack) 설치 및 점검 (`docker --version`, `docker info`)
- [x]  Docker 기본 운영 명령 (`docker images`, `docker ps -a`)
- [x]  hello-world 컨테이너 실행
- [x]  ubuntu 컨테이너 내부 진입 및 명령 수행 (`ls`, `echo`)
- [x]  Dockerfile 기반 커스텀 이미지 빌드 (nginx:alpine 베이스)
- [x]  포트 매핑 접속 (2회, 각기 다른 호스트 포트)
- [x]  바인드 마운트 반영 확인 (변경 전/후)
- [x]  Docker 볼륨 영속성 확인 (컨테이너 삭제 전/후)
- [x]  Git 사용자 설정 및 GitHub · VSCode 연동

## 4) 수행 로그 및 검증

### 4-1. 터미널 기본 조작

```bash
$ pwd
/Users/mac
$ mkdir codyssey-practice
$ cd codyssey-practice
$ pwd
/Users/mac/codyssey-practice

$ touch hello.txt
$ cp hello.txt hello-copy.txt
$ mv hello-copy.txt hello-renamed.txt
$ rm hello-renamed.txt
$ ls -la
total 0
drwxr-xr-x  3 mac  staff   96  7월 28 17:28 .
drwxr-x---+ 19 mac  staff  608  7월 28 17:24 ..
-rw-r--r--  1 mac  staff    0  7월 28 17:27 hello.txt
```

**검증 방법**: `ls -la` 결과로 생성/복사/이름변경/삭제가 의도대로 반영되었는지 매 단계 확인.

### 4-2. 파일/디렉토리 권한 실습

```bash
$ ls -l hello.txt
-rw-r--r--  1 mac  staff  0  7월 28 17:27 hello.txt

$ chmod 600 hello.txt
$ ls -l hello.txt
-rw-------  1 mac  staff  0  7월 28 17:27 hello.txt

$ chmod 755 hello.txt
$ ls -l hello.txt
-rwxr-xr-x  1 mac  staff  0  7월 28 17:27 hello.txt

$ mkdir testdir
$ chmod 700 testdir
$ ls -l
drwx------  2 mac  staff  64  7월 28 17:30 testdir
```

**검증 방법**: 권한 변경 전/후 `ls -l` 결과 비교로 644 → 600 → 755, 디렉토리 기본값 → 700 변경을 확인.

### 4-3. Docker 설치 및 점검 (OrbStack)

```bash
$ docker --version
Docker version 29.4.0, build 9d7ad9f

$ docker info
Client:
 Version: 29.4.0
 Context: orbstack
...
Server:
 Containers: 0
 Running: 0
 Images: 0
 Server Version: 29.4.0
```

**검증 방법**: `Context: orbstack`으로 OrbStack이 Docker 엔진 역할을 정상 수행함을 확인.

### 4-4. 컨테이너 실행 실습

```bash
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

$ docker run -it ubuntu bash
root@986ae7739873:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@986ae7739873:/# echo hi
hi
root@986ae7739873:/# exit
exit

$ docker images
IMAGE                DISK USAGE   CONTENT SIZE
hello-world:latest    18.5kB       10.3kB
ubuntu:latest         178MB        44.4MB

$ docker ps -a
CONTAINER ID   IMAGE         COMMAND   STATUS
986ae7739873   ubuntu        "bash"    Exited (0)
eec57c0f3559   hello-world   "/hello"  Exited (0)
```

**컨테이너 종료/유지 관찰**: `bash` 세션에서 `exit`을 입력하면 컨테이너 내 메인 프로세스가 종료되어 컨테이너도 즉시 정지(Exited) 상태가 된다. 반면 `docker exec`는 이미 실행 중인 컨테이너에 새 프로세스를 추가로 붙이는 방식이라, `exec`로 들어간 세션을 종료해도 원래 컨테이너는 계속 실행 상태를 유지한다.

### 4-5. Dockerfile 기반 커스텀 이미지 제작

**선택한 베이스**: `nginx:alpine` (방식 A — 웹서버 베이스 이미지 활용 + 정적 콘텐츠 교체)

**Dockerfile**:

```docker
FROM nginx:alpine
LABEL description="my custom nginx web server"
COPY site/ /usr/share/nginx/html/
```

**커스텀 포인트**:
- `LABEL description`: 이미지 용도를 명시하기 위한 메타데이터 추가
- `COPY site/ /usr/share/nginx/html/`: nginx 기본 정적 페이지를 직접 작성한 `index.html`로 교체

**빌드 및 실행**:

```bash
$ docker build -t my-web:1.0 .
...
=> [2/2] COPY site/ /usr/share/nginx/html/
=> naming to docker.io/library/my-web:1.0

$ docker images
my-web:1.0    (빌드 완료 확인)
```

### 4-6. 포트 매핑 및 접속 증거

```bash
$ docker run -d -p 8080:80 --name my-web-container my-web:1.0
$ docker run -d -p 8081:80 --name my-web-container2 my-web:1.0
```

- 브라우저 접속 1: `http://localhost:8080/` → “Hello, this is my Docker web server!” 정상 출력 (스크린샷 첨부)
- 브라우저 접속 2: `http://localhost:8081/` → 동일 내용 정상 출력 (스크린샷 첨부)

### 4-7. 바인드 마운트 반영 확인

```bash
$ docker run -d -p 8082:80 --name mount-test -v $(pwd)/site:/usr/share/nginx/html my-web:1.0
```

- 변경 전: `localhost:8082` 접속 시 “Hello, this is my Docker web server!” 출력
- 호스트에서 파일 수정:

```bash
$ cat > site/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>My Docker Web</title></head>
<body><h1>Updated content! (바인드 마운트 테스트)</h1></body>
</html>
EOF
```

- 변경 후: 컨테이너 재시작 없이 `localhost:8082` 새로고침만으로 “Updated content! (바인드 마운트 테스트)” 즉시 반영 확인 (스크린샷 첨부)

**검증 방법**: 호스트 폴더와 컨테이너 내부 경로가 실시간으로 동기화됨을 새로고침 결과로 확인.

### 4-8. Docker 볼륨 영속성 확인

```bash
$ docker volume create mydata
mydata

$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec -it vol-test bash -c "echo hi > /data/hello.txt && cat /data/hello.txt"
hi

$ docker rm -f vol-test
vol-test

$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
$ docker exec -it vol-test2 bash -c "cat /data/hello.txt"
hi
```

**검증 방법**: `vol-test` 컨테이너를 완전히 삭제(`rm -f`)한 뒤, 동일 볼륨(`mydata`)에 연결한 새 컨테이너 `vol-test2`에서 이전에 저장한 `hello.txt` 내용(`hi`)이 그대로 유지됨을 확인 → 컨테이너 생명주기와 무관하게 볼륨 데이터가 영속됨을 증명.

### 4-9. Git 설정 및 GitHub · VSCode 연동

```bash
$ git config --global user.name "eldbsop"
$ git config --global user.email "eldbsop@khu.ac.kr"
$ git config --global init.defaultBranch main
$ git config --list
credential.helper=osxkeychain
init.defaultbranch=main
user.name=eldbsop
user.email=eldbsop@khu.ac.kr
init.defaultbranch=main

$ cd ~
$ git clone https://github.com/eldbsop/codyssey-workstation-practic.git
Cloning into 'codyssey-workstation-practic'...
Receiving objects: 100% (3/3), done.
```

- VSCode 계정 메뉴에서 **“eldbsop (GitHub)”** 로 로그인 완료 확인 (스크린샷 첨부)
- 클론한 저장소를 VSCode로 열어 `README.md` 등 파일 탐색기에서 확인

## 5) 트러블슈팅

### 트러블슈팅 1

- **문제**: `cd codtssey-practice` 실행 시 `No such file or directory` 오류 발생
- **원인 가설**: 디렉토리 이름 오타 (`codyssey` → `codtssey`)
- **확인**: `ls -la`로 실제 생성된 디렉토리명이 `codyssey-practice`임을 재확인
- **해결**: 정확한 이름으로 `cd codyssey-practice` 재입력하여 정상 이동

### 트러블슈팅 2

- **문제**: 바인드 마운트 페이지 갱신 후 브라우저에 한글이 `??` 형태로 깨져 출력됨
- **원인 가설**: `index.html`에 문자 인코딩(`charset`)을 명시하는 `<meta>` 태그가 없어 브라우저가 기본 인코딩으로 잘못 해석
- **확인**: 최초 작성한 `index.html`에 `<meta charset="UTF-8">` 누락 확인
- **해결**: `<head>`에 `<meta charset="UTF-8">`를 추가하여 재작성 후 새로고침 → 한글 정상 출력 확인

### 트러블슈팅 3

- **문제**: `cd ~ git clone ...`처럼 두 명령어를 한 줄에 입력하여 `cd: too many arguments` 오류 발생
- **원인 가설**: 셸 명령어는 한 줄에 하나씩 실행해야 하는데, `cd`의 인자로 `git clone ...` 전체가 잘못 전달됨
- **확인**: 에러 메시지가 `cd`의 인자 개수 오류를 가리킴을 확인
- **해결**: `cd ~`와 `git clone ...`을 별도 줄로 분리하여 재실행, 정상 클론 완료

### 트러블슈팅 4

- **문제**: VSCode에서 `code .` 실행 시 `zsh: command not found: code` 오류 발생
- **원인 가설**: VSCode의 셸 명령줄 도구(`code` CLI)가 PATH에 등록되어 있지 않음
- **확인**: VSCode 명령 팔레트(`Cmd+Shift+P`)에서 `Shell Command: Install 'code' command in PATH` 항목 존재 확인
- **해결**: 해당 명령 실행 후 `code .` 명령 재시도, 또는 VSCode에서 `File > Open Folder`로 직접 폴더를 열어 우회

## 6) 보안 안내

본 문서 및 첨부 스크린샷에는 비밀번호, 토큰, 개인키 등 민감 정보가 포함되지 않도록 마스킹 처리하였습니다.