import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

# In-memory storage for registered clients and commands
clients = {}
commands = {}

class CommandServerHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        client_ip, client_port = self.client_address
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        print(f"Received data: {post_data}")

        if post_data.startswith("register|"):
            self.handle_register(post_data, client_ip)
        elif post_data.startswith("get_command|"):
            self.handle_get_command(post_data)
        elif post_data.startswith("report_result|"):
            self.handle_report_result(post_data)
        else:
            self.send_error(400, "Invalid command")

    def handle_register(self, data, client_ip):
        try:
            parts = data.split("|")
            serial = parts[1]
            computer_name = parts[2]

            clients[serial] = {
                "computer_name": computer_name,
                "ip": client_ip,
                "status": "registered"
            }
            print(f"Registered client: {serial} ({computer_name}) from {client_ip}")
            self.respond(200, "Registration successful")
        except IndexError:
            self.respond(400, "Invalid register message format")

    def handle_get_command(self, data):
        try:
            parts = data.split("|")
            serial = parts[1]

            if serial in commands and commands[serial]:
                command = commands[serial].pop(0)  # Get the next command for the client
                self.respond(200, command + "|10")  # Append suggested polling time (10 seconds)
            else:
                self.respond(200, "no_command|10")  # No command, suggest 10s wait
        except IndexError:
            self.respond(400, "Invalid get_command message format")

    def handle_report_result(self, data):
        try:
            parts = data.split("|", 2)
            serial = parts[1]
            result = parts[2]

            if serial in clients:
                print(f"Result from {serial}: {result}")
                self.respond(200, "Result received")
            else:
                self.respond(400, "Client not registered")
        except IndexError:
            self.respond(400, "Invalid report_result message format")

    def respond(self, status_code, message):
        self.send_response(status_code)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(message.encode("utf-8"))

    def log_message(self, format, *args):
        return  # Suppress default HTTP server logging

def run_server(host="0.0.0.0", port=5074):
    print(f"Starting server on {host}:{port}")
    server_address = (host, port)
    httpd = HTTPServer(server_address, CommandServerHandler)

    # Start a separate thread for interactive command input
    threading.Thread(target=command_input_loop, daemon=True).start()

    print("Server is running...")
    httpd.serve_forever()

def command_input_loop():
    """Allow dynamic input of commands for clients."""
    while True:
        serial = input("Enter the client serial number: ").strip()
        if serial not in clients:
            print(f"No registered client with serial number {serial}.")
            continue

        command = input(f"Enter the command for client {serial}: ").strip()
        if not command:
            print("No command entered.")
            continue

        if serial not in commands:
            commands[serial] = []
        commands[serial].append(command)
        print(f"Command '{command}' added for client {serial}.")

if __name__ == "__main__":
    run_server()
