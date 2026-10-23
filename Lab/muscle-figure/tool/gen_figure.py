# Generates Lab/muscle-figure/assets/figure.svg: placeholder regions, one path per muscle group per view.
import sys
W=200
def m(x): return W-x
def ell(cx,cy,rx,ry):
    return f"M{cx-rx},{cy} a{rx},{ry} 0 1,0 {2*rx},0 a{rx},{ry} 0 1,0 {-2*rx},0 Z"
def poly(pts):
    return "M"+" L".join(f"{x},{y}" for x,y in pts)+" Z"
def pair_ell(cx,cy,rx,ry): return ell(cx,cy,rx,ry)+" "+ell(m(cx),cy,rx,ry)
def pair_poly(pts): return poly(pts)+" "+poly([(m(x),y) for x,y in reversed(pts)])

outline = " ".join([
  ell(100,26,15,18),
  poly([(92,42),(108,42),(108,58),(92,58)]),
  poly([(72,58),(128,58),(140,70),(134,110),(126,170),(74,170),(66,110),(60,70)]),
  pair_poly([(60,68),(52,74),(50,110),(46,150),(44,190),(54,192),(58,152),(64,114),(68,88)]),
  pair_ell(49,200,6,10),
  pair_poly([(74,168),(100,172),(98,250),(94,300),(92,370),(78,370),(74,300),(70,240)]),
  pair_ell(85,378,9,5),
])

front = [
  ("chest", pair_poly([(99,60),(80,62),(72,72),(74,90),(88,96),(99,94)])),
  ("abs", poly([(90,98),(110,98),(111,160),(89,160)])),
  ("obliques", pair_poly([(76,98),(88,100),(88,158),(78,150),(72,120)])),
  ("quads", pair_poly([(80,176),(97,180),(96,240),(92,262),(82,262),(76,230),(76,192)])),
  ("biceps", pair_ell(58,100,6,14)),
  ("forearms", pair_ell(53,150,6,26)),
  ("calves", pair_ell(82,316,6,24)),
  ("adductors", poly([(97,182),(100,186),(103,182),(102,230),(100,236),(98,230)])),
  ("front_delts", pair_ell(70,70,7,9)),
  ("side_delts", pair_ell(61,75,5,10)),
  ("abductors", pair_ell(73,182,4,10)),
  ("neck", poly([(93,44),(107,44),(109,56),(91,56)])),
]
back = [
  ("lats", pair_poly([(74,94),(86,106),(98,110),(98,140),(88,150),(76,128)])),
  ("hamstrings", pair_poly([(78,206),(97,208),(96,262),(82,262),(76,232)])),
  ("glutes", pair_ell(87,188,12,16)),
  ("upper_back", pair_poly([(84,70),(92,72),(98,96),(86,104),(76,92)])),
  ("lower_back", poly([(90,142),(110,142),(112,168),(88,168)])),
  ("traps", poly([(100,48),(118,62),(108,70),(100,96),(92,70),(82,62)])),
  ("triceps", pair_ell(58,100,6,14)),
  ("forearms", pair_ell(53,150,6,26)),
  ("calves", pair_ell(84,300,8,26)),
  ("rear_delts", pair_ell(70,70,7,9)),
  ("side_delts", pair_ell(61,75,5,10)),
  ("abductors", pair_ell(72,182,4,10)),
  ("neck", poly([(93,44),(107,44),(109,56),(91,56)])),
]
out=['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 400">',
     '<!-- Placeholder regions for the muscle figure sketch. One path per muscle group per view,',
     '     listed largest first; the app hit-tests in reverse so small regions win. -->']
for view, regions in (("front",front),("back",back)):
    out.append(f'<g id="{view}">')
    out.append(f'<path id="outline" data-view="{view}" d="{outline}"/>')
    for gid,d in regions:
        out.append(f'<path id="{gid}" data-view="{view}" d="{d}"/>')
    out.append('</g>')
out.append('</svg>')
open(sys.argv[1],'w').write("\n".join(out)+"\n")
ids={g for g,_ in front}|{g for g,_ in back}
print(len(ids), sorted(ids))
