# https://github.com/muety/wakapi

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function wakapi-start() {
    # Create wakapi directory if it doesn't exist
    mkdir -p ~/.wakapi
    
    # if container exists, stop and remove it
    if [ "$(docker ps -aq -f name=wakapi)" ]; then
        echo -e "${YELLOW}🛑 Stopping existing wakapi container...${NC}"
        docker stop wakapi
        echo -e "${YELLOW}🗑️ Removing existing wakapi container...${NC}"
        docker rm wakapi
    fi
    
    echo -e "${YELLOW}🚀 Starting wakapi container...${NC}"

    SALT="$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1)"

    # Run the container
    docker run -d \
        --rm \
        -p 3100:3000 \
        -e "WAKAPI_PASSWORD_SALT=$SALT" \
        -v ~/.wakapi:/data \
        --name wakapi \
        ghcr.io/muety/wakapi:latest
    
    # message that container is running successfully
    if [ "$(docker ps -q -f name=wakapi)" ]; then
        echo -e "${GREEN}✅ Wakapi is running successfully on port: 3100!${NC}"
    else
        echo -e "\033[0;31m❌ Wakapi failed to start.${NC}"
    fi
}
