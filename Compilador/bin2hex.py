def binario_a_hexadecimal(binario):
    """
    Convierte un número binario de 32 bits a hexadecimal.
    """
    decimal = int(binario, 2)
    hexadecimal = hex(decimal)[2:].upper()
    return hexadecimal.zfill(8)  # Asegura que tenga 8 dígitos hexadecimales


def main():
    archivo_entrada = "programa.mem"
    archivo_salida = "Program.hex"

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


if __name__ == "__main__":
    main()
