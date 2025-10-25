import json,uuid,time,os
from http.server import BaseHTTPRequestHandler,HTTPServer
ST=os.environ.get("STORAGE_DIR","/tmp"); os.makedirs(ST,exist_ok=True)

class H(BaseHTTPRequestHandler):
  def _w(self,c,b,ct):
    self.send_response(c)
    self.send_header("Content-Type", ct)
    self.end_headers()
    self.wfile.write(b)

  def do_GET(self):
    if self.path=="/health": self._w(200,b"ok","text/plain"); return
    if self.path.startswith("/v1/plan/"):
      pid=self.path.split("/v1/plan/")[1]; p=os.path.join(ST,pid+".json")
      if os.path.exists(p): self._w(200,open(p,"rb").read(),"application/json")
      else: self._w(404,b'{"error":"not_found"}',"application/json")
      return
    self._w(404,b"","text/plain")

  def do_POST(self):
    if self.path=="/v1/plan/compile":
      pid=str(uuid.uuid4())
      data={"planId":pid,"status":"compiled","createdAt":time.strftime("%Y-%m-%dT%H:%M:%SZ",time.gmtime()),"payload":{}}
      open(os.path.join(ST,pid+".json"),"wb").write(json.dumps(data).encode())
      self._w(200,json.dumps({"planId":pid}).encode(),"application/json"); return
    self._w(404,b"","text/plain")

HTTPServer(("0.0.0.0",9090),H).serve_forever()
