COMPOSE_FILE="/path/to/pihole/docker-compose.yml"

is_running() {
    docker ps --filter "name=pihole" --format "table {{.Names}}" | grep -q pihole
}

start_pihole() {
    echo "Starting Pi-hole..."
    cd /path/to/pihole
    docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Pi-hole started successfully!"
        echo "🌐 Web interface: http://192.168.x.x/admin"
        echo "🔑 Password: [Check docker-compose.yml or use 'password' command to change]"
        echo "🔧 DNS server: 192.168.x.x (configure this in your router/device DNS settings)"
    else
        echo "❌ Failed to start Pi-hole"
    fi
}
stop_pihole() {
    echo "Stopping Pi-hole..."
    cd /path/to/pihole
    docker compose down 2>/dev/null || docker-compose down 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Pi-hole stopped successfully!"
    else
        echo "❌ Failed to stop Pi-hole"
    fi
}
change_password() {
    echo "Changing Pi-hole password..."
    if is_running; then
        echo "Enter new password (leave empty to disable password):"
        read -s new_password
        if [ -z "$new_password" ]; then
            echo "Disabling Pi-hole password..."
            docker exec pihole pihole setpassword
        else
            docker exec pihole pihole setpassword "$new_password"
        fi
        echo "✅ Password updated successfully!"
    else
        echo "❌ Pi-hole is not running. Start it first with: $0 start"
        return 1
    fi
}
open_web_interface() {
    echo "Opening Pi-hole web interface..."
    if is_running; then
        xdg-open "http://192.168.x.x/admin" 2>/dev/null || echo "🌐 Open in browser: http://192.168.x.x/admin"
        echo "🔑 Password: [Check docker-compose.yml or use 'password' command to change]"
    else
        echo "❌ Pi-hole is not running. Start it first with: $0 start"
        return 1
    fi
}
show_status() {
    echo "Pi-hole Status:"
    if is_running; then
        echo "🟢 Running"
        docker ps --filter "name=pihole" --format "table {{.Names}}	{{.Status}}	{{.Ports}}"
    else
        echo "🔴 Stopped"
    fi
}
case "${1:-status}" in
    "start")
        start_pihole
        ;;
    "stop")
        stop_pihole
        ;;
    "restart")
        echo "Restarting Pi-hole..."
        stop_pihole
        sleep 2
        start_pihole
        ;;
    "status")
        show_status
        ;;
    "web")
        open_web_interface
        ;;
    "password")
        change_password
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|web|password}"
        echo ""
        echo "Commands:"
        echo "  start    - Start Pi-hole"
        echo "  stop     - Stop Pi-hole"
        echo "  restart  - Restart Pi-hole"
        echo "  status   - Show Pi-hole status"
        echo "  web      - Open Pi-hole web interface in browser"
        echo "  password - Change Pi-hole admin password"
        exit 1
        ;;
esac
