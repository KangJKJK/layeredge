#!/bin/bash

# 환경 변수 설정
export WORK="/root/LayerEdge-Auto-Bot"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}Laeredge 봇을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처:https://github.com/airdropinsiders/LayerEdge-Auto-Bot${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. 레이어엣지 봇 새로 설치${NC}"
echo -e "${YELLOW}2. 재실행하기${NC}"
echo -e "${YELLOW}3. 레이어엣지 봇 업데이트${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}레이어엣지 봇을 새로 설치합니다.${NC}"

    # 사전 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git

    echo -e "${YELLOW}작업 공간 준비 중...${NC}"
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
        rm -rf "$WORK"
    fi

    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/airdropinsiders/LayerEdge-Auto-Bot.git
    cd "$WORK"

    # Node.js 20 LTS 버전 설치 및 사용
    echo -e "${YELLOW}Node.js 20 LTS 버전을 설치하고 설정 중...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # nvm을 로드합니다
    nvm install 20
    nvm use 20
    npm install

    echo -e "${GREEN}메인계정으로 사용할 월렛을 연결해주세요(REF:hDTQSQOS): https://dashboard.layeredge.io/ ${NC}"
    echo -e "${GREEN}당신의 레퍼럴코드를 기록해두세요. 봇 이용시 새로운 계정을 자동으로 생성하여 레퍼럴을 자동으로 입력할 수 있습니다. ${NC}"
    read -p "위 작업이 끝나면 엔터를 쳐주세요 : "

    # 프록시파일 생성
    echo -e "${YELLOW}프록시 정보를 입력하세요. 입력형식: http://user:pass@ip:port${NC}"
    echo -e "${YELLOW}여러 개의 프록시는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}입력을 마치려면 엔터를 두 번 누르세요.${NC}"

    {
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            # 입력된 프록시 정보를 그대로 저장
            echo "$line"
        done
    } > "$WORK/proxy.txt"

    # 개인키 입력 받기
    echo -e "${GREEN}자동으로 노드를 구동할 계정들의 정보를 입력받습니다.${NC}"
    echo -e "${GREEN}개인키를 한번에 받은 후 지갑주소를 한번에 받을 것입니다. 매칭되는 정보들을 준비하세요.${NC}"
    echo -e "${YELLOW}개인키를 입력하세요. 여러 개의 개인키는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}입력을 마치려면 빈 줄에서 엔터를 누르세요.${NC}"

    # 개인키들을 배열에 저장
    private_keys=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        private_keys+=("$line")
    done

    # 지갑주소 입력 받기
    echo -e "${YELLOW}지갑주소를 입력하세요. 여러 개의 주소는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}위에서 입력한 개인키와 동일한 수의 주소를 입력해야 합니다.${NC}"
    echo -e "${YELLOW}입력을 마치려면 빈 줄에서 엔터를 누르세요.${NC}"

    # 지갑주소들을 배열에 저장
    addresses=()
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        addresses+=("$line")
    done

    # 개수 확인
    if [ ${#private_keys[@]} -ne ${#addresses[@]} ]; then
        echo -e "${RED}에러: 개인키 수(${#private_keys[@]}개)와 지갑주소 수(${#addresses[@]}개)가 일치하지 않습니다.${NC}"
        exit 1
    fi

    # JSON 형식으로 저장
    {
        echo "["
        for i in "${!private_keys[@]}"; do
            if [ $i -gt 0 ]; then
                echo ","
            fi
            echo "    {"
            echo "        \"address\": \"${addresses[$i]}\","
            echo "        \"privateKey\": \"${private_keys[$i]}\""
            echo -n "    }"
        done
        echo
        echo "]"
    } > "$WORK/wallets.json"

    # 봇 구동
    npm run start

    ;;
    
  2)
    echo -e "${GREEN}레이어엣지봇을 재실행합니다.${NC}"
    
    # nvm을 로드합니다
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm use 20

    cd "$WORK"
    
    # 봇 구동
    npm run start
    ;;


  3)
    echo -e "${GREEN}레이어엣지 봇을 업데이트합니다.${NC}"

    # nvm을 로드합니다
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm use 20
    
    # 백업 디렉토리 생성
    BACKUP_DIR="/root/layeredgeback"
    echo -e "${YELLOW}설정 파일 백업 중...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # 중요 파일 백업
    cp "$WORK/wallets.json" "$BACKUP_DIR/" 2>/dev/null
    cp "$WORK/proxy.txt" "$BACKUP_DIR/" 2>/dev/null
    
    # 작업 디렉토리로 이동
    cd "$WORK"
    
    # git pull로 최신 코드 가져오기
    echo -e "${YELLOW}최신 코드를 가져오는 중...${NC}"
    git pull
    
    # 백업했던 파일 복원
    echo -e "${YELLOW}설정 파일 복원 중...${NC}"
    cp "$BACKUP_DIR/wallets.json" "$WORK/" 2>/dev/null
    cp "$BACKUP_DIR/proxy.txt" "$WORK/" 2>/dev/null
    
    # 의존성 패키지 업데이트
    echo -e "${YELLOW}의존성 패키지를 업데이트하는 중...${NC}"
    npm install
    
    echo -e "${GREEN}업데이트가 완료되었습니다.${NC}"

    npm run start
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac
