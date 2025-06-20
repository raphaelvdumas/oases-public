
C  CONSV.FOR
      SUBROUTINE CONSV(IOP, ICON, NSECT, RPROF, BATHY, HMAX,
     &                 C0, Z0, C1, Z1, 
     &                 AX, AY, NOPT, TITLE, FLAG, ICF)

      REAL NRNG
      REAL SECTOR(28), RPROF( * ), BATHY( * )
      REAL FLAG(NOPT,ICF), AX(NOPT,6), AY(NOPT,7)

      DOUBLE PRECISION H0, H1

      DOUBLE PRECISION C0(*), Z0(*)
      DOUBLE PRECISION C1(*), Z1(*)

      CHARACTER*3 BWCOL
      CHARACTER*3 XBTYPE, YBTYPE
      CHARACTER*80 TITLE, TITLEX, TITLEY
      CHARACTER*16 OPTION
      CHARACTER*20 FILENM
      CHARACTER*80 TIX, TIY

      COMMON /CONTUR/ CNTR1(4,4)
      COMMON /LUCONT/ LUCDR, LUBDR, LUCFR, LUBFR

      EQUIVALENCE (TIX,TITLEX), (TIY,TITLEY)

      DATA FLAGRC / 1.0 /
      DATA CAY, NRNG/ 5.0, 5.0/
      DATA X1PL,Y1PL/1.625, 2.0/
      DATA HGTPT,HGTC,LABPT,NDIV,NARC/0.1,0.14,-3,1,5/
      DATA LABC,LWGT/-1,0/

  120 FORMAT(5E15.4)
  126 FORMAT(6E15.4)
  150 FORMAT('CONSV,REV,',A3,'   ')
  401 FORMAT(1H ,F15.4,3X,'  NUMBER OF INPUT PROFILES ')
  402 FORMAT(1H ,F15.4,3X,'  NUMBER OF DATA POINTS ALONG THE Y AXIS')
  403 FORMAT(1H ,F15.4,3X,'  DIVX  ' )
  404 FORMAT(1H ,F15.4,3X,'  DIVY  ' )
  405 FORMAT(1H ,F15.4,3X,'  FLAGRC =0 ROWS, =1 COLUMNS')
  406 FORMAT(1H ,F15.4,3X,'  MIN DEPTH (m) ' )
  407 FORMAT(1H ,F15.4,3X,'  MAX DEPTH (m) ' )
  408 FORMAT(1H ,F15.4,3X,'  SOURCE DEPTH (m) ' )
  409 FORMAT(1H ,F15.4,3X,'  NUMBER OF GRID POINTS ALONG THE X AXIS ' )
  410 FORMAT(1H ,F15.4,3X,'  NUMBER OF GRID POINTS ALONG THE Y AXIS ' )
  411 FORMAT(1H ,F15.4,3X,'  NUMBER OF DATA POINTS IN THE BDR FILE ')
  412 FORMAT(1H ,F15.4,3X,'  DUMMY ' )
  413 FORMAT(1H ,F15.4,3X,'  CAY   ' )
  414 FORMAT(1H ,F15.4,3X,'  NRNG  ' )
  415 FORMAT(1H ,F15.4,3X,'  ZMIN ' )
  416 FORMAT(1H ,F15.4,3X,'  ZMAX ' )
  417 FORMAT(1H ,F15.4,3X,'  ZINC ' )
  418 FORMAT(1H ,F15.4,3X,'  X ORIGIN OF PLOT IN INCHES ' )
  419 FORMAT(1H ,F15.4,3X,'  SIGMA ' )
  420 FORMAT(1H ,F15.4,3X,'  Y ORIGIN OF PLOT IN INCHES ' )
  421 FORMAT(1H ,F15.4,3X,'  NSM   ' )
  422 FORMAT(1H ,F15.4,3X,'  HGTPT ' )
  423 FORMAT(1H ,F15.4,3X,'  HGTC ' )
  424 FORMAT(1H ,F15.4,3X,'  LABPT ' )
  425 FORMAT(1H ,F15.4,3X,'  NDIV ' )
  426 FORMAT(1H ,F15.4,3X,'  NARC ' )
  427 FORMAT(1H ,F15.4,3X,'  LABC ' )
  428 FORMAT(1H ,F15.4,3X,'  LWGT ' )
  550 FORMAT('CONSV.CDR           ')
  650 FORMAT('CONSV.BDR           ')
  700 FORMAT('BOTTOM   0')
  800 FORMAT(A16)
  810 FORMAT(A20)
  820 FORMAT('Range (km)  ',17('    '))
  840 FORMAT('Depth (m)   ',17('    '))
  850 FORMAT(A80)
  900 FORMAT(1X,F15.4,3X,'  XLEFT',/,F16.4,4X,' XRIGHT',/,F16.4,3X,
     *'  X AXIS LENGTH IN CM ',/,F16.4,4X,' XINC')
  901 FORMAT(1X,F15.4,3X,'  YUP',/,F16.4,3X,'  YDOWN',/,F16.4,3X,
     *'  Y AXIS LENGTH IN CM ',/,F16.4,3X,'  YINC')
  950 FORMAT(1H ,F15.4,1X,'    RMIN',/,F16.4,2X,'   RMAX')




C     DEFAULT CHOICE OF MIN NUMBER OF GRID POINTS ON CONTUR MATRIX
      NGX= 41
      NGY= 25


      IF( RPROF(NSECT)*1.0E3 .LT. AX(IOP,4) )   THEN
C       THE LAST SVP IS REPEATED AT MAX RANGE. 
        SECTOR(1)= NSECT+1
        RMAX= AX(IOP,2)
      ELSE
        SECTOR(1)= NSECT
        RMAX= RPROF(NSECT)*1.0E3
      END IF
      WRITE(LUBDR,120) SECTOR
      RMIN= 0.0

      NPLX= SECTOR(1)
      NPLY= 0
      NPOINT= 0
      HMAX= 0.0

      REWIND(10)
      READ(10) MINMOD,MAXMOD
      DO 1000   ISECT= 1, NSECT
        READ(10) RKM
        READ(10) R1, R2, H0, H1, ND0, ND1
C       READ(10) (BETA(J), J= 1, 3), SCATT, CC0, CC1
        READ(10) DUMMY
C       SVP IN WATER COLUMN
        READ(10) (Z0(J), C0(J), J= 1, ND0)
C       SVP IN SEDIMENT LAYER
        IF(ND1.GT.0)   READ(10) (Z1(J), C1(J), J= 1, ND1)
C ****
C           IN THE PRESENT VERSION THE CONTOUR OF THE SED LAYER 
C           IN NOT IMPLEMENTED
CXCX        Z1(1)= 1.0E-3
CXCX        NSED= ND1  
        NSED= 0
C ****
C       BOTTOM
        READ(10) C2, C2S

        NPLY= MAX(NPLY,ND0+NSED)
        NPOINT= NPOINT + ND0+NSED
        WRITE(LUBDR,*) RKM*1.0E3, ND0+NSED
        WRITE(LUBDR,*) (SNGL(Z0(I)),SNGL(C0(I)),I=1,ND0), 
     &                 (SNGL(Z1(I))+SNGL(Z0(ND0)),C1(I),I=1,NSED)

 1000 CONTINUE 

      IF( RPROF(NSECT)*1.0E3 .LT. AX(IOP,4) )   THEN
         WRITE(LUBDR,*) RMAX, ND0+ND1
        WRITE(LUBDR,*) (SNGL(Z0(I)),SNGL(C0(I)),I=1,ND0), 
     &                 (SNGL(Z1(I))+SNGL(Z0(ND0)),C1(I),I=1,ND1)
        NPOINT= NPOINT + ND0+ND1
      END IF

      DUMMY= 0.0




C     WRITE THE *.CDR FILE

      DIVX=1.0E-3
      DIVY=1.0
      XBTYPE='LIN'
      YBTYPE='LIN'
      WRITE(TIX,820)
      WRITE(TIY,840)
C
      IF( FLAG(IOP,4) .GT. 0.0 )   THEN
        BWCOL= 'COL'
      ELSE
        BWCOL= 'B/W'
      END IF

      WRITE(FILENM,550)
C
      WRITE(OPTION,150) BWCOL
      WRITE(LUCDR,800) OPTION
      WRITE(LUCDR,850) TITLE
C
      WRITE(FILENM,650)
      WRITE(LUCDR,810) FILENM

      WRITE(LUCDR,850) TITLEX
      WRITE(LUCDR,950) RMIN, RMAX
      XLEN= ABS(AX(IOP,2) - AX(IOP,1)) / AX(IOP,3)
      WRITE(LUCDR,900) AX(IOP,1), AX(IOP,2), XLEN, AX(IOP,4)

      WRITE(LUCDR,850) TITLEY
      YLEN= ABS(AY(IOP,2) - AY(IOP,1)) / AY(IOP,3)
      WRITE(LUCDR,901) AY(IOP,1), AY(IOP,2), YLEN, AY(IOP,4)
C   
C     NUMBER OF input PROFILES
      WRITE(LUCDR,401) FLOAT(NPLX)
C   
      WRITE(LUCDR,412) DUMMY
C
      WRITE(LUCDR,403) DIVX              
      WRITE(LUCDR,404) DIVY              
      WRITE(LUCDR,405) FLAGRC              

      WRITE(LUCDR,406) HMIN
      WRITE(LUCDR,407) HMAX
      WRITE(LUCDR,412) DUMMY

C     NUMBER OF GRID POINTS ALONG X AXIS
      WRITE(LUCDR,409) FLOAT( MAX(NPLX,NGX) )
      WRITE(LUCDR,410) FLOAT( MAX(NPLY,NGY) )
C
      WRITE(LUCDR,412) DUMMY              
C
      WRITE(LUCDR,411) FLOAT(NPOINT)

      WRITE(LUCDR,413) CAY              
C
      WRITE(LUCDR,414) NRNG              
C     MIN CONTOUR LEVEL (m/s)
      WRITE(LUCDR,415) CNTR1(4,1)
C     MAX CONTOUR LEVEL (m/s)
      WRITE(LUCDR,416) CNTR1(4,2)
C     CONTOUR LEVEL STEP (m/s)
      WRITE(LUCDR,417) CNTR1(4,3)
C     X ORIGIN OF PLOT IN INCHES
      WRITE(LUCDR,418) X1PL
C
      WRITE(LUCDR,419) DUMMY
C     Y ORIGIN OF PLOT IN INCHES
      WRITE(LUCDR,420) Y1PL
C
      NSM= MAX(0, NINT(CNTR1(4,4)))
      WRITE(LUCDR,421) FLOAT(NSM)
C
      WRITE(LUCDR,422) HGTPT
C
      WRITE(LUCDR,423) HGTC
C
      WRITE(LUCDR,424) FLOAT(LABPT)
C
      WRITE(LUCDR,425) FLOAT(NDIV)
C
      WRITE(LUCDR,426) FLOAT(NARC)
C
      WRITE(LUCDR,427) FLOAT(LABC)
C
      WRITE(LUCDR,428) FLOAT(LWGT)

C     BOTTOM SHADING
      WRITE(LUCDR,700)
      WRITE(LUCDR,*) RPROF(1), MAX( HMAX, MAX(AY(IOP,1),AY(IOP,2)) )
      DO 1500   ISECT= 1, NSECT
      WRITE(LUCDR,*) RPROF(ISECT), BATHY(ISECT)
 1500 CONTINUE
      WRITE(LUCDR,*) 1.0E-3*RMAX, BATHY(NSECT)
      WRITE(LUCDR,*) 1.0E-3*RMAX,
     &               MAX( HMAX, MAX(AY(IOP,1),AY(IOP,2)) )

      RETURN

      END
