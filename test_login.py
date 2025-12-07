import urllib.request
import urllib.error
import json
import time

# Configuración
URL = "http://127.0.0.1:8000/api/v1/login/"
CI = "12345678" 
PASSWORD = "demo123" 

print(f"Probando conexión a: {URL}")

def test_login():
    # Probamos con CI que es lo que espera el servidor
    payload = {"ci": CI, "password": PASSWORD}
    print(f"\n--- Enviando: {payload} ---")
    
    try:
        data = json.dumps(payload).encode('utf-8')
        req = urllib.request.Request(URL, data=data, headers={'Content-Type': 'application/json'})
        
        with urllib.request.urlopen(req) as response:
            print(f"Status: {response.getcode()}")
            print(f"Content-Type: {response.headers.get('Content-Type')}")
            content = response.read().decode('utf-8')
            print("Respuesta (primeros 500 chars):")
            print(content[:500])
            
            try:
                json_resp = json.loads(content)
                print("\n✅ ES UN JSON VÁLIDO")
                print(json.dumps(json_resp, indent=2))
            except:
                print("\n⚠️ RESPUESTA NO ES JSON (Probablemente HTML)")
            
    except urllib.error.HTTPError as e:
        print(f"Error HTTP {e.code}")
        try:
            print(e.read().decode('utf-8')[:500])
        except:
            print("No se pudo leer el error")
    except Exception as e:
        print(f"Error de conexión: {e}")

# Esperar un poco por si el servidor se está reiniciando
print("Esperando 2 segundos...")
time.sleep(2)
test_login()
