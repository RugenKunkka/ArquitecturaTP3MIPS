import serial
import threading
import sys
import argparse
import time

def setup_argparse():
    # Create an ArgumentParser object
    parser = argparse.ArgumentParser(description='A script to receive and print command-line parameters.')

    # Add command-line arguments with default values
    parser.add_argument('--mode', type=str, default='STEP', help='Modo de Operacion del MIPS. (CONT or STEP)')
    parser.add_argument('--port', type=str, default='COM13', help='Puerto de comunicacion serial.')
    parser.add_argument('--baudrate', type=int, default=9600, help='Baud Rate de la comunicacion serial.')
    parser.add_argument('--path', type=str, default=r"C:\Users\UserTest1\College\CompArq\DebugUnit\DebugUnit.srcs\sim_1\new\Program.hex"  , help='Path hacia el programa a cargar.')
    parser.add_argument('--log', action='store_true', help='Para loggear la terminal')
    args = parser.parse_args()
    print(args)
    return args

def load_program(path):
    list_to_send = []
    try:   
        with open(path, 'r') as file:
            file_contents = file.read()
            lines = file_contents.split('\n')
        for line in lines:
            for i in range(6, -1, -2):
                hex_str = line[i:i+2]
                print("Hex: "+hex_str+" Bin: "+bin(int(hex_str, 16))[2:].zfill(8))
                list_to_send.append(bytes.fromhex(hex_str));        
    except FileNotFoundError:
            print("The file does not exist or cannot be found.")

    return list_to_send

def setup_ser(args):
    try:
        return  serial.Serial(port=args.port, baudrate=args.baudrate, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE)
    except Exception as e:
        print(f"Error al establecer conexion: {str(e)}")
        ser.close()
        sys.exit()

def send_keyword(ser,keyword):
    try:
        ser.write(bytes.fromhex(keyword))
    except Exception as e:
        print(f"Error al enviar: {str(e)}")        

def send_program(ser,bytes_from_program):
    try:
        for byte_type in bytes_from_program:
            ser.write(byte_type)
    except Exception as e:
        print(f"Error al enviar: {str(e)}")        


def recibir_numero():
    try:
        while True:
            counter = 0 
            # Espera y lee un byte desde UART
            byte_recibido = ser.read(1)
            
            if byte_recibido:
                # Convierte el byte recibido a un número decimal

                numero_recibido = int.from_bytes(byte_recibido, byteorder='big')
                
                # Imprime el número recibido
                #print(f"{hex(numero_recibido)[2:].zfill(2).upper()}",end='',flush=True)
                print(f"{hex(numero_recibido)[2:].zfill(2).upper()}")


    except Exception as e:
        print(f"Error al recibir: {str(e)}")


if __name__ == "__main__"   :

    PROG_KW = "50"
    STEPMOD_KW = "53"

    bytes_from_program = [];

    print("\n1. Configuracion: ")
    args = setup_argparse()

    print("\n2. Cargando programa hex...")
    bytes_from_program = load_program(args.path)
    input("<Presiona ENTER para programar y ejecutar>")

    ser = setup_ser(args)

    print("\n3. Programando...")
    send_keyword(ser,PROG_KW);
    send_program(ser,bytes_from_program);
    send_keyword(ser,STEPMOD_KW);

    thread_recepcion = threading.Thread(target=recibir_numero)
    thread_recepcion.daemon = True
    thread_recepcion.start()


    try:
        while True:
            time.sleep(5)
            input("\n<Presiona ENTER para hacer otro step>\n")
            send_keyword(ser,STEPMOD_KW);
        
    except KeyboardInterrupt:
        print("\nCtrl+C pressed. Exiting the program.")
        ser.close()


'''
    try:
        while True:
            input("\n<Presiona ENTER para run step>\n")
            send_keyword(ser,STEPMOD_KW);
            print("\n4. Escuchando...")

    except KeyboardInterrupt:
        print("\nCtrl+C pressed. Exiting the program.")
        ser.close()
'''        

