import tkinter as tk
from tkinter import ttk, messagebox
import serial
import serial.tools.list_ports

BAUD_RATE = 9600
READ_INTERVAL_MS = 100
ser = None
connected_port = None


def refresh_ports():
    """Find available USB/COM ports."""
    current = port_box.get()
    ports = []

    for port in serial.tools.list_ports.comports():
        description = port.description or "Unknown device"
        ports.append(f"{port.device} - {description}")

    port_box["values"] = ports

    # Preserve the user's selection when possible.
    if current in ports:
        port_box.set(current)
    elif ports:
        port_box.current(0)
    else:
        port_box.set("")
        status_label.config(text="No COM ports found")

    if ports:
        status_label.config(text=f"Found {len(ports)} port(s)")


def connect():
    """Connect to the selected Arduino USB/COM port."""
    global ser, connected_port

    if ser and ser.is_open:
        disconnect()

    selected = port_box.get().strip()

    if not selected:
        messagebox.showwarning(
            "No Port Selected",
            "Connect the Arduino Uno and select a COM port first."
        )
        return

    # Example selection: COM3 - Arduino Uno
    port_name = selected.split(" - ", 1)[0]

    try:
        ser = serial.Serial(
            port=port_name,
            baudrate=BAUD_RATE,
            timeout=0.1
        )
        connected_port = port_name

        # Opening a serial connection may reset an Arduino Uno.
        status_label.config(
            text=f"Connected to {port_name}; waiting for Arduino..."
        )
        connect_button.config(state="disabled")
        disconnect_button.config(state="normal")
        port_box.config(state="disabled")

        output.insert(
            "end",
            f"\n--- Connected to {port_name} at {BAUD_RATE} baud ---\n"
        )
        output.see("end")

        # Allow the Uno time to restart and print its startup message.
        root.after(1500, read_serial)

    except (serial.SerialException, ValueError) as error:
        ser = None
        connected_port = None
        messagebox.showerror(
            "Connection Failed",
            f"Could not open {port_name}.\n\n"
            f"Details: {error}\n\n"
            "Check the USB cable, selected port, and whether "
            "another program is using the port."
        )


def read_serial():
    """Display serial lines from the connected Arduino."""
    if not ser or not ser.is_open:
        return

    try:
        while ser.in_waiting > 0:
            line = ser.readline().decode(
                "utf-8", errors="replace"
            ).strip()

            if line:
                output.insert("end", line + "\n")
                output.see("end")

    except serial.SerialException as error:
        status_label.config(text=f"USB serial error: {error}")
        disconnect()
        return

    root.after(READ_INTERVAL_MS, read_serial)


def disconnect():
    """Close the serial connection."""
    global ser, connected_port

    old_port = connected_port

    if ser:
        try:
            if ser.is_open:
                ser.close()
        except serial.SerialException:
            pass

    ser = None
    connected_port = None

    status_label.config(text="Disconnected")
    connect_button.config(state="normal")
    disconnect_button.config(state="disabled")
    port_box.config(state="readonly")

    if old_port:
        output.insert("end", f"\n--- Disconnected from {old_port} ---\n")
        output.see("end")


def clear_output():
    output.delete("1.0", "end")


def close_app():
    disconnect()
    root.destroy()


# ---------------- GUI ----------------

root = tk.Tk()
root.title("SmartHatch Arduino USB Connection")
root.geometry("720x470")
root.minsize(580, 380)

main = ttk.Frame(root, padding=12)
main.pack(fill="both", expand=True)

ttk.Label(
    main,
    text="SmartHatch — Arduino Uno USB Connection",
    font=("Arial", 13, "bold")
).pack(anchor="w", pady=(0, 12))

ttk.Label(main, text="Select Arduino USB / COM port:").pack(anchor="w")

port_box = ttk.Combobox(main, state="readonly")
port_box.pack(fill="x", pady=(4, 10))

buttons = ttk.Frame(main)
buttons.pack(fill="x", pady=(0, 10))

ttk.Button(
    buttons, text="Refresh Ports", command=refresh_ports
).pack(side="left", padx=(0, 8))

connect_button = ttk.Button(
    buttons, text="Connect", command=connect
)
connect_button.pack(side="left", padx=(0, 8))

disconnect_button = ttk.Button(
    buttons,
    text="Disconnect",
    command=disconnect,
    state="disabled"
)
disconnect_button.pack(side="left", padx=(0, 8))

ttk.Button(
    buttons, text="Clear Output", command=clear_output
).pack(side="left")

status_label = ttk.Label(main, text="Disconnected")
status_label.pack(anchor="w", pady=(0, 6))

ttk.Label(main, text="Arduino serial output:").pack(anchor="w")

output_frame = ttk.Frame(main)
output_frame.pack(fill="both", expand=True, pady=(4, 0))

output_scrollbar = ttk.Scrollbar(output_frame)
output_scrollbar.pack(side="right", fill="y")

output = tk.Text(
    output_frame,
    height=15,
    wrap="word",
    yscrollcommand=output_scrollbar.set
)
output.pack(side="left", fill="both", expand=True)
output_scrollbar.config(command=output.yview)

root.protocol("WM_DELETE_WINDOW", close_app)

refresh_ports()
root.mainloop()
