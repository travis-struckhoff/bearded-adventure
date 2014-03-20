import array
import sys
sys.setrecursionlimit(100000)

def flood_fill(array, x, y):
    if x > 99 or x < 0 or y > 99 or y < 0:
        return
    if array[x*100+y] == 'x':
        return
    
    array[x*100+y] = 'x'

    flood_fill(array,x-1,y)
    flood_fill(array,x+1,y)
    flood_fill(array,x,y-1)
    flood_fill(array,x,y+1)

if __name__ == '__main__':
    verts = array.array('c',('.',)*10000)
    # print(verts)
    flood_fill(verts, 0, 0)
    print(verts)