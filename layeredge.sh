#!/bin/bash

# 환경 변수 설정
export WORK="/root/LayerEdge/LayerEdge"
export BACKUP_DIR="/root/layeredgeback"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}LayerEdge 봇을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처: https://github.com/MeoMunDep/LayerEdge${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. LayerEdge 봇 새로 설치${NC}"
echo -e "${YELLOW}2. 재실행하기${NC}"
echo -e "${YELLOW}3. LayerEdge 봇 업데이트${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}LayerEdge 봇을 새로 설치합니다.${NC}"

    # 기존 작업 폴더가 있다면 먼저 삭제
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 폴더 삭제 중...${NC}"
        rm -rf /root/LayerEdge
    fi

    # 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git
    
    # Wine 설치
    echo -e "${YELLOW}Wine 설치 중...${NC}"
    
    if [ -f /etc/debian_version ]; then
        # WineHQ 저장소 추가
        sudo mkdir -pm755 /etc/apt/keyrings
        sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
        sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -sc)/winehq-$(lsb_release -sc).sources
        
        # Wine 최신 stable 버전 설치
        sudo apt update
        sudo apt install -y --install-recommends winehq-stable
        
    elif [ -f /etc/arch-release ]; then
        sudo pacman -Sy wine --noconfirm
        
    elif [ -f /etc/fedora-release ]; then
        sudo dnf install -y wine
        
    else
        echo -e "${RED}지원되지 않는 리눅스 배포판입니다.${NC}"
        exit 1
    fi

    # Wine 종속성 설치
    echo -e "${YELLOW}Wine 종속성 설치 중...${NC}"
    if [ -f /etc/debian_version ]; then
        # Ubuntu/Debian용 Wine 설치
        sudo dpkg --add-architecture i386
        sudo apt update
        sudo apt install -y --install-recommends wine64 wine32 \
            libwine libwine:i386 fonts-wine \
            winetricks \
            winbind \
            xvfb \
            cabextract \
            p7zip-full \
            mono-complete

        # Wine 초기 설정
        echo -e "${YELLOW}Wine 초기 설정 중...${NC}"
        export DISPLAY=:0
        
        # 기존 Xvfb 프로세스 정리
        killall Xvfb 2>/dev/null
        rm -f /tmp/.X0-lock 2>/dev/null
        
        # Xvfb 시작
        Xvfb :0 -screen 0 1024x768x16 &
        sleep 2  # Xvfb가 완전히 시작될 때까지 대기

        # Wine 설정
        WINEARCH=win64 WINEPREFIX=~/.wine wineboot -u
        
        # Windows 구성요소 설치
        echo -e "${YELLOW}Windows 구성요소 설치 중...${NC}"
        DISPLAY=:0 winetricks -q vcrun2019
        DISPLAY=:0 winetricks -q dotnet48
        DISPLAY=:0 winetricks allfonts
        DISPLAY=:0 winetricks settings win10
    fi
    
    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/MeoMunDep/LayerEdge.git
    cd "$WORK"

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
    } > "$WORK/proxies.txt"

    # 개인키 입력 받기
    echo -e "${YELLOW}개인키를 입력하세요. 여러 개의 개인키는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}입력을 마치려면 빈 줄에서 엔터를 누르세요.${NC}"

    {
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            # 입력된 개인키를 그대로 저장
            echo "$line"
        done
    } > "$WORK/privateKeys.txt"

    # 추천 코드 입력 받기
    echo -e "${YELLOW}추천 코드를 입력하세요:${NC}"
    read -p "추천 코드: " referral_code

    # configs.json 파일 생성/수정
    {
        echo "{"
        echo "  \"timeZone\": \"en-US\","
        echo "  \"skipInvalidProxy\": false,"
        echo "  \"delayEachAccount\": [1, 1],"
        echo "  \"timeToRestartAllAccounts\": 300,"
        echo "  \"howManyAccountsRunInOneTime\": 1,"
        echo "  \"referralCode\": \"$referral_code\""
        echo "}"
    } > "$WORK/configs.json"

    echo -e "${GREEN}추천 코드가 성공적으로 저장되었습니다.${NC}"
    
    # exe 파일 실행
    echo -e "${YELLOW}LayerEdge 실행 중...${NC}"
    export DISPLAY=:0
    Xvfb :0 -screen 0 1024x768x16 &
    wine meomundep.exe
    ;;
    
  2)
    echo -e "${GREEN}LayerEdge 봇을 재실행합니다.${NC}"
    cd "$WORK"
    wine meomundep.exe
    ;;

  3)
    echo -e "${GREEN}LayerEdge 봇을 업데이트합니다.${NC}"
    
    # 백업 디렉토리 생성
    echo -e "${YELLOW}설정 파일 백업 중...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # 중요 파일 백업
    cp "$WORK/privateKeys.txt" "$BACKUP_DIR/" 2>/dev/null
    cp "$WORK/proxies.txt" "$BACKUP_DIR/" 2>/dev/null
    cp "$WORK/configs.json" "$BACKUP_DIR/" 2>/dev/null
    
    # 기존 폴더 삭제 후 새로 클론
    cd /root
    rm -rf LayerEdge
    git clone https://github.com/MeoMunDep/LayerEdge.git
    cd "$WORK"
    
    # 백업했던 파일 복원
    echo -e "${YELLOW}설정 파일 복원 중...${NC}"
    cp "$BACKUP_DIR/privateKeys.txt" "$WORK/" 2>/dev/null
    cp "$BACKUP_DIR/proxies.txt" "$WORK/" 2>/dev/null
    cp "$BACKUP_DIR/configs.json" "$WORK/" 2>/dev/null
    
    echo -e "${GREEN}업데이트가 완료되었습니다.${NC}"
    wine meomundep.exe
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac
