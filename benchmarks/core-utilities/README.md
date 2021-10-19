Under each benchmark directory:
1. Run cases on original binary:
	- `python run.py original`

2. Run cases on debloated binary:
	- `python run.py debloated`

3. Verify if the both the cases match:
	- `python run.py verify`


<!-- 
4. Debloat the binary:
	- `python run.py debloat`

5. Infer more code paths that are not executed for training cases:
	- `python run.py extend_debloat heuristic_level(i.e., 1 ~ 4)`
	- Retry step 3. -->
