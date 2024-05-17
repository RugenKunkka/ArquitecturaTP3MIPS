#!/usr/bin/python3

import sys
from asm2bin import Converter

def asm2bin(file):
    if file.endswith(".asm"):
            with open(file, 'r') as asm_file:
                print("daaale papa1!!")
                bin_lines = Converter.assembly(asm_file.readlines())
                print("SALIMOSS!!!")
                out_file = file.replace('asm', 'bin')
                print("daaale papa2!!")
            with open(out_file, 'w') as out_file:
                bin_lines = map(lambda x: x + '\n', bin_lines)
                out_file.writelines(bin_lines)
                print (file, 'converted to bin')
    print ("** Conversion finished **")

def binario_a_hexadecimal(binario):
    """
    Convierte un número binario de 32 bits a hexadecimal.
    """
    decimal = int(binario, 2)
    hexadecimal = hex(decimal)[2:].upper()
    return hexadecimal.zfill(8)  # Asegura que tenga 8 dígitos hexadecimales


def bin2hex_func(file):
    archivo_entrada = file.replace('asm', 'mem')
    archivo_salida = file.replace('asm', 'hex32')

    try:
        with open(archivo_entrada, 'r') as f_entrada, open(archivo_salida, 'w') as f_salida:
            # Lee cada línea del archivo de entrada
            for linea in f_entrada:
                # Elimina los espacios en blanco al principio y al final de la línea
                linea = linea.strip()
                
                # Verifica si la línea no está vacía
                if linea:
                    # Convierte el binario de 32 bits a hexadecimal
                    hexadecimal = binario_a_hexadecimal(linea)
                    
                    # Escribe el hexadecimal en el archivo de salida
                    f_salida.write(hexadecimal + '\n')
    except FileNotFoundError:
        print(f"El archivo '{archivo_entrada}' no se encontró.")
    except Exception as e:
        print("Ocurrió un error:", e)
    else:
        print(f"Se ha creado el archivo '{archivo_salida}' con éxito.")

def hex32tohex8(file):
    archivo_original = file.replace('asm', 'hex32')
    archivo_nuevo = file.replace('asm', 'hex8')

    with open(archivo_original, 'r') as archivo_lectura:
        # Lee el contenido del archivo original
        contenido = archivo_lectura.readlines()

    # Abre el archivo de escritura en modo escritura
    with open(archivo_nuevo, 'w') as archivo_escritura:
        # Itera sobre el contenido del archivo original línea por línea
        for linea in contenido:
            # Elimina el salto de línea al final de la línea
            linea = linea.strip()
            # Itera sobre los pares de caracteres en orden inverso
            for i in range(len(linea) - 2, -1, -2):
                # Escribe el par de caracteres en el archivo nuevo, seguido de un salto de línea
                archivo_escritura.write(linea[i:i+2] + '\n')

if __name__ == "__main__":

    # Ejemplo uso: \Compilador$ python3 asm2bin2hex.py .\orioriaddu.asm

    if len(sys.argv) > 1:
        file = sys.argv[1]
    else:
        file = "default.asm" # Probar path obsulto si  except FileNotFoundError

    print("-------------------------ASM to BIN-------------------------------")
    asm2bin(file)
    print("-------------------------BIN to HEX32------------------------")
    bin2hex_func(file)
    print("-------------------------HEX32 to HEX8----------------------")
    hex32tohex8(file)