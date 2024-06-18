import serial
import threading
import sys
import argparse
import time

primeraEjecucion=True

def setup_argparse():
    # Create an ArgumentParser object
    parser = argparse.ArgumentParser(description='A script to receive and print command-line parameters.')

    # Add command-line arguments with default values
    parser.add_argument('--mode', type=str, default='CONT', help='Modo de Operacion del MIPS. (CONT or STEP)')
    parser.add_argument('--port', type=str, default='COM4', help='Puerto de comunicacion serial.')
    parser.add_argument('--baudrate', type=int, default=9600, help='Baud Rate de la comunicacion serial.')
    parser.add_argument('--path', type=str, default=r"D:\Facultad\Arquitectura de computadoras\MIS_TPS\ArquitecturaTP3MIPS\pruebaJ1.hex"  , help='Path hacia el programa a cargar.')
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
                
                #print(f"{hex(numero_recibido)[2:].zfill(2).upper()}")
                
                guardar_datos(f"{hex(numero_recibido)[2:].zfill(2).upper()}")


    except Exception as e:
        print(f"Error al recibir: {str(e)}")
        
def guardar_datos(digitos, archivo='datos.txt'):
    """
    Guarda un string de dos dígitos en un archivo sin sobrescribir el contenido existente.

    Parámetros:
    digitos (str): El string que contiene los dos dígitos a guardar.
    archivo (str): El nombre del archivo donde se guardarán los datos.
    """
    # Verificar que el string tenga exactamente 2 caracteres
    if len(digitos) != 2:
        raise ValueError("El string debe contener exactamente 2 dígitos.")
    
    # Abrir el archivo en modo de agregar ('a')
    with open(archivo, 'a') as f:
        # Escribir los dos dígitos seguidos de una nueva línea
        f.write(f"{digitos}\n")
        
def borrar_contenido_archivo(archivo='datos.txt'):
    """
    Abre un archivo y borra su contenido. Si el archivo no existe, lo crea vacío.

    Parámetros:
    archivo (str): El nombre del archivo cuyo contenido se va a borrar.
    """
    # Abrir el archivo en modo de escritura ('w') borra su contenido
    with open(archivo, 'w') as f:
        pass  # No es necesario escribir nada, solo abrir en 'w' ya borra el contenido

def contar_lineas_archivo(archivo='datos.txt'):
    """
    Cuenta el número de líneas en un archivo.

    Parámetros:
    archivo (str): El nombre del archivo del cual se contarán las líneas.

    Retorna:
    int: El número de líneas en el archivo.
    """
    with open(archivo, 'r') as f:
        lineas = f.readlines()
        return len(lineas)
        
def reformatear_archivo(archivo_entrada='datos.txt', archivo_salida='datos_formateados.txt'):
    """
    Lee los datos de 'archivo_entrada', los reformatea y los guarda en 'archivo_salida'.
    Si el archivo de salida existe, su contenido será sobrescrito.

    Parámetros:
    archivo_entrada (str): El nombre del archivo de entrada con los datos originales.
    archivo_salida (str): El nombre del archivo de salida donde se guardarán los datos reformateados.
    """
    # Array de nombres predefinidos
    nombres = [
        "PC", "Reg0", "Reg1", "Reg2", "Reg3", "Reg4", "Reg5", "Reg6", "Reg7", "Reg8", "Reg9",
        "Reg10", "Reg11", "Reg12", "Reg13", "Reg14", "Reg15", "Reg16", "Reg17", "Reg18", "Reg19",
        "Reg20", "Reg21", "Reg22", "Reg23", "Reg24", "Reg25", "Reg26", "Reg27", "Reg28", "Reg29",
        "Reg30", "Reg31", "Reg32", "Reg33", "Reg34", "Reg35", 
    ]

    try:
        contador=0
        # Abre el archivo de entrada en modo de lectura
        with open(archivo_entrada, 'r') as f_entrada:
            # Lee todas las líneas del archivo de entrada
            lineas = f_entrada.readlines()
        
        # Limpiar las líneas eliminando espacios en blanco alrededor y saltos de línea
        lineas = [linea.strip() for linea in lineas]
        
        # Lista para almacenar los datos reformateados
        datos_reformateados = []
        
        # Itera sobre las líneas en grupos de 4
        for i in range(0, len(lineas), 4):
            # Extrae un grupo de hasta 4 líneas
            grupo = lineas[i:i+4]
            # Invierte el orden del grupo
            grupo_invertido = grupo[::-1]
            # Une las líneas del grupo invertido en una sola cadena
            cadena_reformateada = ''.join(grupo_invertido)
            # Añade el nombre correspondiente del array y concatena con la cadena reformateada
            nombre = nombres[i // 4] if i // 4 < len(nombres) else f"PC{i // 4 + 1}"
            datos_reformateados.append(nombre+": " + cadena_reformateada+"  ")
        
        # Abre el archivo de salida en modo de escritura ('w') para sobrescribir su contenido
        with open(archivo_salida, 'w') as f_salida:
            # Escribe cada línea reformateada en el archivo de salida
            for linea in datos_reformateados:
                f_salida.write(linea)
                contador=contador+1
                if contador==4:
                    f_salida.write('\n')
                    contador=0

    except FileNotFoundError:
        # Maneja el caso en que el archivo de entrada no existe
        print(f"El archivo {archivo_entrada} no existe.")


def leer_y_imprimir_archivo(nombre_archivo):
    """
    Lee el contenido de 'nombre_archivo' y lo imprime en pantalla.

    Parámetros:
    nombre_archivo (str): El nombre del archivo que se desea leer e imprimir.
    """
    try:
        # Abre el archivo en modo de lectura
        with open(nombre_archivo, 'r') as archivo:
            # Lee todas las líneas del archivo
            lineas = archivo.readlines()
            # Imprime cada línea en pantalla
            for linea in lineas:
                print(linea.strip())
    except FileNotFoundError:
        # Maneja el caso en que el archivo no existe
        print(f"El archivo {nombre_archivo} no existe.")
        
        
if __name__ == "__main__"   :

    borrar_contenido_archivo()
    PROG_KW = "50"
    STEPMOD_KW = "53"

    contModKeyword = "44"

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
    if args.mode=='STEP' :
        print("Ejecutamos en modo STEP")
        send_keyword(ser,STEPMOD_KW);
    elif args.mode=='CONT' :
        print("Ejecutamos en modo CONT")
        send_keyword(ser,contModKeyword);

    print("asdasdads")
    thread_recepcion = threading.Thread(target=recibir_numero)
    thread_recepcion.daemon = True
    thread_recepcion.start()


    try:
        while True:
            time.sleep(2)
            numero_de_lineas = contar_lineas_archivo()
            #if primeraEjecucion and args.mode=='STEP':
            #   borrar_contenido_archivo()*/
            if args.mode=='STEP' and numero_de_lineas!=0:
                print(f"----------------------------Contenido del archivo formateado----------------------------")
                reformatear_archivo()
                leer_y_imprimir_archivo("datos_formateados.txt")
                borrar_contenido_archivo()
            elif args.mode=='CONT' and numero_de_lineas!=0:
                print(f"----------------------------Contenido del archivo formateado----------------------------")
                reformatear_archivo()
                leer_y_imprimir_archivo("datos_formateados.txt")
                borrar_contenido_archivo()
                
            
            print(f"El modo ejecutado es: {args.mode}")
            print(f"El archivo tiene {numero_de_lineas} líneas.")
            print(f"Variable bool es primera ejecucion {primeraEjecucion}")
            
            input("\n<Presiona ENTER para hacer otro step>\n")
            primeraEjecucion=False
            if args.mode=='STEP' :
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

