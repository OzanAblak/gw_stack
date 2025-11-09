## NEGATIF E2E SONUCLARI (Guncel) 
 
- N1  /v1/plan/compile GET            -> 405 
- N2  /v1/plan/compile bozuk JSON     -> 400 
- N3  /v1/plan/compile bos govde      -> 400 
- N4  /v1/plan/compile text/plain     -> 400 
- N5  gateway /nope                   -> 404 
- N6  gateway /v1/                    -> 404 
- N7  gateway /v1/ DELETE             -> 404 
- N8  gateway /v1/ HEAD               -> 404 
- N9  gwfwd /nope                     -> 404 
- N10 gwfwd /v1/plan/compile bozuk    -> 400 
- N11 planner /v1/plan/compile {}     -> 400 
- N12 gateway /health POST            -> 405 
