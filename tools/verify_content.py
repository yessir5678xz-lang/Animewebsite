"""Verify model and surface contents against the checked-in provenance manifests."""
import hashlib,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[1]/'game'
def verify():
    count=0;size=0
    library=json.loads((ROOT/'data/library.json').read_text())
    maps=[m for a in json.loads((ROOT/'data/surfaces.json').read_text())['materials'] for m in a['maps']]
    for record in library['models']+maps:
        relative=record['path'].removeprefix('res://');path=ROOT/relative
        if not path.is_file():raise SystemExit(f'Missing {relative}. Restore the surface source packs or run tools/import_surfaces.py as documented.')
        with path.open('rb') as stream:actual=hashlib.file_digest(stream,'sha256').hexdigest()
        if actual!=record['sha256']:raise SystemExit('Content hash mismatch: '+relative)
        count+=1;size+=path.stat().st_size
    print(f'PASS: {count} licensed model/texture files, {size:,} source bytes verified')
if __name__=='__main__':verify()
