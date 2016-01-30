implicit real*8 (a-h, o-z)
real*8, allocatable::  LOC(:,:,:),ZLOC(:)
real*8 :: temp(5)
integer*8 :: a(3),linetotal,residue,totalnum
integer*8 :: x,y,z,xindex,yindex,zindex,indexnum,line
!!$*   constant 'c' below is 2m/hbar**2 in units of 1/eV Ang^2 (value is
!!$*   adjusted in final decimal places to agree with VASP value; program
!!$*   checks for discrepancy of any results between this and VASP values)

data c/0.262465831d0/ 
pi=4.*atan(1.)
      
!!$*   input
     
open(unit=10,file='loc')
open(unit=11,file='zloc')
if (iost.ne.0) write(6,*) 'open error - iostat =',iost            
write(*,*)1
read(10,*) (a(j),j=1,3)
write(*,*)2
!do j=1,3
!a(j)=nint(a(j))
!enddo
write(*,*) (a(j),j=1,3)
totalnum  = a(1)*a(2)*a(3)
linetotal = totalnum/5+1
residue   = mod(totalnum,5)
write(*,*) "linetotal=",linetotal," residue=",residue
allocate(LOC(0:a(1)-1,0:a(2)-1,0:a(3)-1))
allocate(ZLOC(0:a(3)-1))

do line=1,linetotal
!last line
    if (line.eq.linetotal) then
        read(10,*) (temp(j),j=1,residue)
 !      write(*,*) (temp(j),j=1,residue)
        do ind=0,residue-1
           indexnum=5*(line-1)+ind
           xindex=mod(indexnum,a(1))
           yindex=mod((indexnum-xindex)/a(1),a(2))
           zindex=(indexnum-xindex-yindex*a(1))/(a(1)*a(2))
           LOC(xindex,yindex,zindex)=temp(ind+1)
 !          write(*,*)xindex,yindex,zindex,LOC(xindex,yindex,zindex)
        enddo
    else
        read(10,*) (temp(j),j=1,5)
 !       write(*,*) (temp(j),j=1,5)
        do ind=0,4
           indexnum=5*(line-1)+ind
           xindex=mod(indexnum,a(1))
           yindex=mod((indexnum-xindex)/a(1),a(2))
           zindex=(indexnum-xindex-yindex*a(1))/(a(1)*a(2))
           LOC(xindex,yindex,zindex)=temp(ind+1)
!           write(*,*)xindex,yindex,zindex,LOC(xindex,yindex,zindex)
        enddo
    endif    
    !write(*,*) (temp(j),j=1,5)
    ! LOC(:,:)
    ! write(*,*) LOC(1,1)
enddo
close(unit=10)

write(*,*)"start to average over z axis"
do zindex=0,a(3)-1
do yindex=0,a(2)-1
do xindex=0,a(1)-1
    ZLOC(zindex)= ZLOC(zindex)+LOC(xindex,yindex,zindex)
enddo
enddo
    write(*,*) zindex,ZLOC(zindex)
enddo

ZLOC=ZLOC/dble(a(1)*a(2))

do zindex=0,a(3)-1
    write(*,*) zindex,ZLOC(zindex)
    write(11,*) zindex,ZLOC(zindex)
enddo

stop
end program
