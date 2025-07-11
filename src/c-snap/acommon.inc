C    ACOMMON.INC

      INTEGER ALEFT, ARIGHT, CURRNT
      INTEGER ANMED, ALTOT, ANMAT, AMINM
      INTEGER AMH0, AMSED
      INTEGER AMQTY

      REAL AC0, AC1, AC2, AC2S, AR2, AH0H1
      REAL AR1

      DOUBLE PRECISION AH0, AH1

      REAL MODSET(1 , 1 )
      DOUBLE PRECISION EIGVL( MODEN )
      DOUBLE PRECISION ADH0, ADSED

      COMPLEX GAMTL, GAMBL, PHITL, PHIBL
      COMPLEX PR0(NPOINT)

      COMMON /AA01/ ANMED(2), ALTOT(2), ANMAT(2), AMINM(2)
      COMMON /AA02/ AMH0(2), AMSED(2), ADH0(2), ADSED(2)
      COMMON /AA03/ AC0(2), AC1(2), AC2(2), AC2S(2),
     &              AR1(2), AR2(2), AH0H1(2)
      COMMON /AA04/ AH0(2), AH1(2)
      COMMON /AA05/ AMQTY(2)
      COMMON/ A006/ GAMTL(MODEN), GAMBL(MODEN)
      COMMON /A007/ PHITL(MODEN), PHIBL(MODEN)
      COMMON /A008/ DEPTTL, DEPTBL
      COMMON /CEIGVL/ EIGVL
      COMMON /CMODSE/ MODSET
      COMMON /PARA4/ NMAM2, NPAM2
      COMMON /POSITN/ ALEFT, ARIGHT, CURRNT
      COMMON /ZLR/ ZL(NPOINT), ZR(NPOINT)

      EQUIVALENCE (PR0(1), ZL(1)), (PR0(NPHALF+1), ZR(1))

C     END
