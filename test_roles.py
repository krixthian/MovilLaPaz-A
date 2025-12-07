import urllib.request
import urllib.error
import json

# Configuración
BASE_URL = "http://127.0.0.1:8000/api/v1"
CI = "12345678" 
PASSWORD = "demo123" 

def test_login():
    url = f"{BASE_URL}/login/"
    payload = {"ci": CI, "password": PASSWORD}
    print(f"\n--- Probando Login: {url} ---")
    
    try:
        data = json.dumps(payload).encode('utf-8')
        req = urllib.request.Request(url, data=data, headers={'Content-Type': 'application/json'})
        
        with urllib.request.urlopen(req) as response:
            content = response.read().decode('utf-8')
            json_resp = json.loads(content)
            print("✅ Login Exitoso")
            print(f"Rol detectado: {json_resp.get('rol')}")
            
            if 'hijos' in json_resp:
                print(f"Hijos encontrados: {len(json_resp['hijos'])}")
                for h in json_resp['hijos']:
                    print(f" - {h['nombre_completo']} ({h['curso']})")
                    # Probar citaciones con el primer hijo
                    test_citaciones(h['ci'])
                    break
            
            if 'cursos' in json_resp:
                print(f"Cursos encontrados: {len(json_resp['cursos'])}")

    except Exception as e:
        print(f"❌ Error Login: {e}")
        if hasattr(e, 'read'):
            print(e.read().decode('utf-8'))

def test_citaciones(ci_estudiante):
    url = f"{BASE_URL}/citaciones/?ci_estudiante={ci_estudiante}"
    print(f"\n--- Probando Citaciones: {url} ---")
    
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req) as response:
            content = response.read().decode('utf-8')
            json_resp = json.loads(content)
            print("✅ Citaciones OK")
            print(f"Total citaciones: {len(json_resp.get('items', []))}")
            print(json.dumps(json_resp, indent=2))
    except Exception as e:
        print(f"❌ Error Citaciones: {e}")

test_login()
