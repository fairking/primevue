if not exist node_modules mkdir node_modules
attrib +h node_modules
del /q node_modules\*
for /d %%x in (node_modules\*) do @rd /s /q "%%x"
npm install
pause