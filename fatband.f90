implicit real*8 (a-h, o-z) 
character(len=79)::buffer,buffer1
integer :: nk,nb,na,nor,nso  !kpoint band atom spd soc
integer :: numatom ! how many atoms for calculating fatband
integer :: exchange! just a intermedia
integer :: position,num,nkpoint,nband,natom,norbit,nsoc,aa,atombegin,atomend,no1,no2,no3
real*8, allocatable ::coeff(:,:,:,:,:) !nkpoint,nband,natom,norbit,nsoc
real*8, allocatable ::tcoeff(:,:,:,:) !nkpoint,nband,norbit,nsoc
real*8, allocatable :: nenergy(:,:),nocc(:,:),coeffatom1(:,:),coeffatom2(:,:)!nkpoint,nband
integer, allocatable :: atom(:)! numatom
write(*,*) "how many orbitals spd=10"
read(*,*) nor

write(*,*) "spin-orbit coupling? no 1 yes 4"
read(*,*) nso

open(10,file='PROCAR')
read(10,*) buffer

read(10,"(a)") buffer
write(*,*) buffer

position=index(buffer,":")
buffer(1:position)=""

position=index(buffer,":")
buffer(position-10:position)=""

position=index(buffer,":")
buffer(position-10:position)=""

read(buffer,*) nk,nb,na
write(*,*) nk,nb,na

allocate(coeff(nk,nb,na,nor,nso))
allocate(tcoeff(nk,nb,nor,nso))
allocate(nenergy(nk,nb))
allocate(nocc(nk,nb))
allocate(coeffatom1(nk,nb))
allocate(coeffatom2(nk,nb))


 do nkpoint=1,nk

    read(10,*) buffer

   do nband=1,nb
 
      read(10,*) buffer
      read(10,*) buffer
    
      do nsoc=1,nso  
  
        do natom=1,na
    
              read(10,*) num, (coeff(nkpoint,nband,natom,norbit,nsoc),norbit=1,nor)
        end do
       
          read(10,"(a)") buffer
          position=index(buffer,"o")
          buffer(position-1:position+1)=""
          read(buffer,*) (tcoeff(nkpoint,nband,norbit,nsoc),norbit=1,nor)

      end do

   !do nn=1,2*na+1
   ! read(10,*) buffer
   !end do
  
   end do

end do



!!!!atoms you need
write(*,*) "how many atoms for calculating fatband"
read(*,*) numatom

allocate(atom(numatom))

do ii=1,numatom
 write(*,*)"please write out the order of the Atom", ii, "in the POSCAR" 
 read(*,*) atom(ii)
end do


coeffatom1=0
coeffatom2=0

do nkpoint=1,nk
     do nband=1,nb
       do ii=1,numatom
         exchange=atom(ii)
         coeffatom1(nkpoint,nband)=coeffatom1(nkpoint,nband)+coeff(nkpoint,nband,exchange,10,1)
      
       end do
          
         coeffatom2(nkpoint,nband)=coeffatom1(nkpoint,nband)/tcoeff(nkpoint,nband,10,1)
     end do
end do


open(12,file='EIGENVAL')
open(15,file='fatband.dat')

read(12,*) buffer
write(15,*) buffer
read(12,*) buffer
write(15,*) buffer
read(12,*) buffer
write(15,*) buffer
read(12,*) buffer
write(15,*) buffer
read(12,*) buffer
write(15,*) buffer
read(12,*) no1,no2,no3
write(15,*) no1,no2,no3
write(15,*) "    "

do nkpoint=1,nk
read(12,*) buffer
write(15,*) buffer
do nband=1,nb
read(12,*) aa,nenergy(nkpoint,nband)
write(15,"(I4,F16.8,F16.8,F16.8)") aa, nenergy(nkpoint,nband), coeffatom1(nkpoint,nband), coeffatom2(nkpoint,nband)
end do
write(15,*) "    " 
end do



deallocate(coeff)
deallocate(tcoeff)
deallocate(nenergy)
deallocate(nocc)
deallocate(coeffatom1)
deallocate(coeffatom2)
deallocate(atom)


    
close(10)
close(12)
close(15)
stop 
end
