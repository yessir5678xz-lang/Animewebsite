"""Restore v0.3 surface sources from verified release ZIPs into this checkout.
Usage: python tools/restore_surface_packs.py /directory/containing/the/three/zips
"""
import hashlib,json,pathlib,stat,sys,zipfile,os
ROOT=pathlib.Path(__file__).resolve().parents[1]
def restore(directory):
    manifest=json.loads((ROOT/'tools/source-packs.json').read_text())
    for entry in manifest:
        archive=pathlib.Path(directory)/entry['name']
        with archive.open('rb') as f:digest=hashlib.file_digest(f,'sha256').hexdigest()
        if digest!=entry['sha256']:raise SystemExit('Checksum mismatch: '+archive.name)
        with zipfile.ZipFile(archive) as z:
            for member in z.infolist():
                p=pathlib.PurePosixPath(member.filename)
                if p.is_absolute() or '..' in p.parts or not member.filename.startswith('game/assets/enrichment/surfaces/'):raise SystemExit('Unsafe archive path')
                if stat.S_ISLNK(member.external_attr>>16):raise SystemExit('Symlink not allowed')
                target=ROOT/p
                if not target.resolve().is_relative_to(ROOT.resolve()):raise SystemExit('Path escapes checkout')
                target.parent.mkdir(parents=True,exist_ok=True)
                import shutil
                with z.open(member) as source,target.with_suffix(target.suffix+'.restore').open('wb') as output:shutil.copyfileobj(source,output)
                os.replace(target.with_suffix(target.suffix+'.restore'),target)
        print('Restored',archive.name)
if __name__=='__main__':
    restore(sys.argv[1])
    from verify_content import verify
    verify()
