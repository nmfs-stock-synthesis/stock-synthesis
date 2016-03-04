//  SS_Label_Section_4.99 #INITIALIZE_SECTION (not used in SS)
INITIALIZATION_SECTION

//  SS_Label_Section_5.0 #PARAMETER_SECTION
PARAMETER_SECTION
//  {
//  SS_Label_Info_5.0.1 #Setup convergence critera and max func evaluations
 LOCAL_CALCS
    if(readparfile>=1)
    {cout<<" read parm file"<<endl;
    ad_comm::change_pinfile_name("ss3.par");}
    maximum_function_evaluations.allocate(func_eval.indexmin(),func_eval.indexmax());
    maximum_function_evaluations=func_eval;
    convergence_criteria.allocate(func_conv.indexmin(),func_conv.indexmax());
    convergence_criteria=func_conv;
 END_CALCS

!!//  SS_Label_Info_5.0.2 #Create dummy_parm that will be estimated even if turn_off_phase is set to 0
  init_bounded_number dummy_parm(0,2,dummy_phase)  //  estimate in phase 0

!!//  SS_Label_Info_5.1.1 #Create MGparm vector and associated arrays
  // natural mortality and growth
  init_bounded_number_vector MGparm(1,N_MGparm2,MGparm_LO,MGparm_HI,MGparm_PH)
  matrix MGparm_trend(1,N_MGparm_trend,styr,YrMax+1);
  matrix MGparm_block_val(1,N_MGparm,styr,YrMax+1);
  init_bounded_matrix MGparm_dev(1,N_MGparm_dev,MGparm_dev_minyr,MGparm_dev_maxyr,-10,10,MGparm_dev_PH)
  matrix MGparm_dev_rwalk(1,N_MGparm_dev,MGparm_dev_minyr,MGparm_dev_maxyr);
  vector L_inf(1,N_GP*gender);
  vector Lmax_temp(1,N_GP*gender);
  vector CV_delta(1,N_GP*gender);
  matrix VBK(1,N_GP*gender,0,nages);
  vector Richards(1,N_GP*gender);

  vector Lmin(1,N_GP*gender);
  vector Lmin_last(1,N_GP*gender);
//  vector natM1(1,N_GP*gender)
//  vector natM2(1,N_GP*gender)
  matrix natMparms(1,N_natMparms,1,N_GP*gender)
  3darray natM(1,nseas,1,N_GP*gender*N_settle_timings,0,nages)   //  need nseas to capture differences due to settlement
  3darray surv1(1,nseas,1,N_GP*gender*N_settle_timings,0,nages)
  3darray surv2(1,nseas,1,N_GP*gender*N_settle_timings,0,nages)
  vector CVLmin(1,N_GP*gender)
  vector CVLmax(1,N_GP*gender)
  vector CV_const(1,N_GP*gender)
  matrix mgp_save(styr,YrMax,1,N_MGparm2);
  vector mgp_adj(1,N_MGparm2);
  matrix Cohort_Growth(styr,YrMax,0,nages)
  3darray Cohort_Lmin(1,N_GP*gender,styr,YrMax,0,nages)
  vector VBK_seas(0,nseas);

  3darray wtlen_seas(0,nseas,1,N_GP,1,8);  //  contains seasonally adjusted wtlen_p
  matrix wtlen_p(1,N_GP,1,8);
  vector MGparm_dev_stddev(1,N_MGparm_dev)
  vector MGparm_dev_rho(1,N_MGparm_dev)  // determines the mean regressive characteristic: with 0 = no autoregressive; 1= all autoregressive
  3darray wt_len(1,nseas,1,N_GP*gender,1,nlength)  //  stores wt at mid-bin

//  following wt_len are defined for 1,N_GP, but only use gp=1 due to complications in vbio, exp_ms and sizefreq calc
  3darray wt_len2(1,nseas,1,N_GP,1,nlength2)    //  stores wt at midbin; stacked genders
  3darray wt_len2_sq(1,nseas,1,N_GP,1,nlength2)    //  stores wt at midbin^2; stacked genders
  3darray wt_len_low(1,nseas,1,N_GP,1,nlength2)  //  wt at lower edge of size bin
  3darray wt_len_fd(1,nseas,1,N_GP,1,nlength2-1)  //  first diff of wt_len_low

  matrix mat_len(1,N_GP,1,nlength)
  matrix fec_len(1,N_GP,1,nlength)   // fecundity at length
  matrix mat_fec_len(1,N_GP,1,nlength)
  matrix mat_age(1,N_GP,0,nages)
  matrix Hermaphro_val(1,N_GP,0,nages)

  matrix catch_mult(styr-1,YrMax,1,Nfleet)

 LOCAL_CALCS
   mat_len=1.0;
   mat_age=1.0;
   mat_fec_len=1.0;
   fec_len=1.0;
 END_CALCS

  3darray age_age(0,N_ageerr,1,n_abins2,0,gender*nages+gender-1)
  3darray age_err(1,N_ageerr,1,2,0,nages) // ageing imprecision as stddev for each age

// Age-length keys for each gmorph
  4darray ALK(1,N_subseas*nseas,1,gmorph,0,nages,1,nlength)
  matrix exp_AL(0,nages2,1,nlength2);
  matrix exp_AL_ret(0,nages2,1,nlength2);
  3darray Sd_Size_within(1,N_subseas*nseas,1,gmorph,0,nages)  //  2*nseas stacks begin of seas and end of seas
  3darray Sd_Size_between(1,N_subseas*nseas,1,gmorph,0,nages)  //  2*nseas stacks begin of seas and end of seas
  4darray Ave_Size(styr-3*nseas,TimeMax_Fcast_std+nseas,1,N_subseas,1,gmorph,0,nages)
  3darray CV_G(1,N_GP*gender,1,N_subseas*nseas,0,nages);   //  temporary storage of CV enroute to sd of len-at-age
  3darray Save_Wt_Age(styr-3*nseas,TimeMax_Fcast_std+1,1,gmorph,0,nages)
  3darray Wt_Age_beg(1,nseas,1,gmorph,0,nages)
  3darray Wt_Age_mid(1,nseas,1,gmorph,0,nages)

  3darray migrrate(styr-3,YrMax,1,do_migr2,0,nages)
  3darray recr_dist(1,N_GP*gender,1,N_settle_timings,1,pop);
!!//  SS_Label_Info_5.1.2 #Create SR_parm vector, recruitment vectors
  init_bounded_number_vector SR_parm(1,N_SRparm2,SRvec_LO,SRvec_HI,SRvec_PH)
  number two_sigmaRsq;
  number half_sigmaRsq;
  number sigmaR
  number rho;
  number dirichlet_Parm;
 LOCAL_CALCS
  Ave_Size.initialize();
//  if(SR_parm(N_SRparm2)!=0.0 || SRvec_PH(N_SRparm2)>0) {SR_autocorr=1;} else {SR_autocorr=0;}  // flag for recruitment autocorrelation
  if(SR_parm_1(N_SRparm2,3)!=0.0 || SR_parm_1(N_SRparm2,7)>0)
    {SR_autocorr=1;}
  else
    {SR_autocorr=0;}
  // flag for recruitment autocorrelation
  echoinput<<" Do recruitment_autocorr: "<<SR_autocorr<<endl;
  if(do_recdev==1)
  {k=recdev_start; j=recdev_end; s=1; p=-1;}
  else if(do_recdev==2)
  {s=recdev_start; p=recdev_end; k=1; j=-1;}
  else
  {s=1; p=-1; k=1; j=-1;}

 END_CALCS

  vector biasadj(styr-nages,YrMax)  // biasadj as used; depends on whether a recdev is estimated or not
  vector biasadj_full(styr-nages,YrMax)  //  full time series of biasadj values, only used in defined conditions
  number sd_offset_rec

  init_bounded_number_vector recdev_cycle_parm(1,recdev_cycle,recdev_cycle_LO,recdev_cycle_HI,recdev_cycle_PH)

//  init_bounded_dev_vector recdev_early(recdev_early_start,recdev_early_end,recdev_LO,recdev_HI,recdev_early_PH)
  init_bounded_vector recdev_early(recdev_early_start,recdev_early_end,recdev_LO,recdev_HI,recdev_early_PH)
  init_bounded_dev_vector recdev1(k,j,recdev_LO,recdev_HI,recdev_PH)
  init_bounded_vector recdev2(s,p,recdev_LO,recdev_HI,recdev_PH)
  init_bounded_vector Fcast_recruitments(recdev_end+1,YrMax,recdev_LO,recdev_HI,Fcast_recr_PH2)
  vector recdev(recdev_first,YrMax);

 LOCAL_CALCS
  if(Do_Impl_Error>0)
//  {k=max_phase+1;}
  {k=Fcast_recr_PH2;}
  else
  {k=-1;}
 END_CALCS
  init_bounded_vector Fcast_impl_error(endyr+1,YrMax,-1,1,k)

//  SPAWN-RECR:   define some spawning biomass and recruitment entities
  number SPB_current;                            // Spawning biomass
  number SPB_vir_LH
  number Recr_virgin
  number SPB_virgin
  number SPR_unf
  number SPR_trial
//  vector S1(0,1);
  3darray SPB_pop_gp(styr-3,YrMax,1,pop,1,N_GP)         //Spawning biomass
  vector SPB_yr(styr-3,YrMax)
  vector SPB_B_yr(styr-3,YrMax)  //  mature biomass (no fecundity)
  vector SPB_N_yr(styr-3,YrMax)   //  mature numbers
  number equ_mat_bio
  number equ_mat_num
  !!k=0;
  !!if(Hermaphro_Option!=0) k=1;

  3darray MaleSPB(styr-3,YrMax*k,1,pop,1,N_GP)         //Male Spawning biomass

  matrix SPB_equil_pop_gp(1,pop,1,N_GP);
  matrix MaleSPB_equil_pop_gp(1,pop,1,N_GP);
  number SPB_equil;
  number SPR_temp;  //  used to pass quantity into Equil_SpawnRecr
  number Recruits;                            // Age0 Recruits
  matrix Recr(1,pop,styr-3,YrMax)         //Recruitment
  matrix exp_rec(styr-3,YrMax,1,4) //expected value for recruitment: 1=spawner-recr only; 2=with environ and cycle; 3=with bias_adj; 4=with dev
  matrix Nmid(1,gmorph,0,nages);
  matrix Nsurv(1,gmorph,0,nages);
  3darray natage_temp(1,pop,1,gmorph,0,nages)
  4darray Save_PopLen(styr-3*nseas,TimeMax_Fcast_std+1,1,2*pop,1,gmorph,1,nlength)
  4darray Save_PopWt(styr-3*nseas,TimeMax_Fcast_std+1,1,2*pop,1,gmorph,1,nlength)
  4darray Save_PopAge(styr-3*nseas,TimeMax_Fcast_std+1,1,2*pop,1,gmorph,0,nages)

  number ave_age    //  average age of fish in unfished population; used to weight R1

!!//  SS_Label_Info_5.1.3 #Create F parameters and associated arrays and constants
  init_bounded_number_vector init_F(1,N_init_F,init_F_LO,init_F_HI,init_F_PH)
  matrix est_equ_catch(1,nseas,1,Nfleet)

  !!if(Do_Forecast>0) {k=TimeMax_Fcast_std+1;} else {k=TimeMax+nseas;}
  4darray natage(styr-3*nseas,k,1,pop,1,gmorph,0,nages)  //  add +1 year
  4darray catage(styr-nseas,TimeMax,1,Nfleet,1,gmorph,0,nages)
  4darray equ_catage(1,nseas,1,Nfleet,1,gmorph,0,nages)
  4darray equ_numbers(1,nseas,1,pop,1,gmorph,0,3*nages)
  4darray equ_Z(1,nseas,1,pop,1,gmorph,0,nages)
  matrix catage_tot(1,gmorph,0,nages)//sum the catches for all fleets, reuse matrix each year
  matrix Hrate(1,Nfleet,styr-3*nseas,k) //Harvest Rate for each fleet
  3darray catch_fleet(styr-3*nseas,TimeMax_Fcast_std,1,Nfleet,1,6)  //  1=sel_bio, 2=kill_bio; 3=ret_bio; 4=sel_num; 5=kill_num; 6=ret_num
  matrix annual_catch(styr,YrMax,1,6)  //  same six as above
  matrix annual_F(styr,YrMax,1,2)  //  1=sum of hrate (if Pope fmethod) or sum hrate*seasdur if F; 2=Z-M for selected ages
  3darray equ_catch_fleet(1,6,1,nseas,1,Nfleet)

  matrix fec(1,gmorph,0,nages)            //relative fecundity at age, is the maturity times the weight-at-age times eggs/kg for females
  matrix make_mature_bio(1,gmorph,0,nages)  //  mature female weight at age
  matrix make_mature_numbers(1,gmorph,0,nages)  //  mature females at age
  matrix virg_fec(1,gmorph,0,nages)
  vector Equ_SpawnRecr_Result(1,2);
  number fish_bio;
  number fish_bio_r;
  number fish_bio_e;
  number fish_num_e;
  number fish_num;
  number fish_num_r;
  number vbio;
  number totbio;
  number smrybio;
  number smrynum;
  number smryage;  // mean age of the summary numbers (not accounting for settlement timing)
  number catch_mnage;  //  mean age of the catch (not accounting for settlement timing or season of the catch)
  number catch_mnage_d;  // total catch numbers for calc of mean age
  number harvest_rate;                        // Harvest rate
  number maxpossF;

  4darray Z_rate(styr-3*nseas,k,1,pop,1,gmorph,0,nages)
  3darray Zrate2(1,pop,1,gmorph,0,nages)

 LOCAL_CALCS
  if(F_Method==2)    // continuous F
//    {k=Nfleet*(TimeMax-styr+1);}
     {k=N_Fparm;}
  else
    {k=-1;}
 END_CALCS
 init_bounded_number_vector F_rate(1,k,0.,Fparm_max,Fparm_PH)

  vector Nmigr(1,pop);
  number Nsurvive;
  number YPR_tgt_enc;
  number YPR_tgt_dead;
  number YPR_tgt_N_dead;
  number YPR_tgt_ret;
  number YPR_spr; number Vbio_spr; number Vbio1_spr; number SPR_actual;

  number YPR_Btgt_enc;
  number YPR_Btgt_dead;
  number YPR_Btgt_N_dead;
  number YPR_Btgt_ret;
  number YPR_Btgt; number Vbio_Btgt; number Vbio1_Btgt;
  number Btgt; number Btgttgt; number SPR_Btgt; number Btgt_Rec;
  number Bspr; number Bspr_rec;

  number YPR    // variable still used in SPR series
  number MSY
  number Bmsy
  number Recr_msy
  number YPR_msy_enc;
  number YPR_msy_dead;
  number YPR_msy_N_dead;
  number YPR_msy_ret;

  number YPR_enc;
  number YPR_dead;
  number YPR_N_dead;
  number YPR_ret;
  number MSY_Fmult;
  number SPR_Fmult;
  number Btgt_Fmult;

  number caa;
   number Fmult;
   number Fcast_Fmult;
   number Fcurr_Fmult;
   number Fchange;
   number last_calc;
   matrix Fcast_RelF_Use(1,nseas,1,Nfleet);
   matrix Bmark_RelF_Use(1,nseas,1,Nfleet);
   number alpha;
   number beta;
   number MSY_SPR;
   number GenTime;
   vector cumF(1,gmorph);
   vector maxF(1,gmorph);
   number Yield;
   number Adj4010;

//  !!k1 = styr+(endyr-styr)*nseas-1 + nseas + 1;
//  !!y=k1+N_Fcast_Yrs*nseas-1;

!!//  SS_Label_Info_5.1.4 #Create Q_parm and associated arrays
  init_bounded_number_vector Q_parm(1,Q_Npar,Q_parm_LO,Q_parm_HI,Q_parm_PH)

  matrix Svy_log_q(1,Nfleet,1,Svy_N_fleet);
  matrix Svy_q(1,Nfleet,1,Svy_N_fleet);
  matrix Svy_se_use(1,Nfleet,1,Svy_N_fleet)
  matrix Svy_est(1,Nfleet,1,Svy_N_fleet)    //  will store expected survey in normal or lognormal units as needed
  vector surv_like(1,Nfleet) // likelihood of the indices
  matrix Q_dev_like(1,Nfleet,1,2) // likelihood of the Q deviations

  vector disc_like(1,Nfleet) // likelihood of the discard biomass
  vector mnwt_like(1,Nfleet) // likelihood of the mean body wt

  matrix exp_disc(1,Nfleet,1,disc_N_fleet)
  3darray retain(styr-3,YrMax,1,Nfleet,1,nlength2)
  vector retain_M(1,nlength)
  3darray discmort(styr-3,YrMax,1,Nfleet,1,nlength2)
  vector discmort_M(1,nlength)
  vector exp_mnwt(1,nobs_mnwt)

  matrix Morphcomp_exp(1,Morphcomp_nobs,6,5+Morphcomp_nmorph)   // expected value for catch by growthpattern

  3darray SzFreqTrans(1,SzFreq_Nmeth*nseas,1,nlength2,1,SzFreq_Nbins_seas_g);

!!//  SS_Label_Info_5.1.5 #Selectivity-related parameters
  init_bounded_number_vector selparm(1,N_selparm2,selparm_LO,selparm_HI,selparm_PH)
  matrix selparm_trend(1,N_selparm_trend,styr,YrMax+1);
  matrix selparm_block_val(1,N_selparm,styr,YrMax+1);

  init_bounded_matrix selparm_dev(1,N_selparm_dev,selparm_dev_minyr,selparm_dev_maxyr,-10,10,selparm_dev_PH)
  matrix selparm_dev_rwalk(1,N_selparm_dev,selparm_dev_minyr,selparm_dev_maxyr)
  vector selparm_dev_stddev(1,N_selparm_dev)
  vector selparm_dev_rho(1,N_selparm_dev)  // determines the mean regressive characteristic: with 0 = no autoregressive; 1= all autoregressive
  4darray sel_l(styr-3,YrMax,1,Nfleet,1,gender,1,nlength)
  4darray sel_l_r(styr-3,YrMax,1,Nfleet,1,gender,1,nlength)   //  selex x retained
  4darray discmort2(styr-3,YrMax,1,Nfleet,1,gender,1,nlength)
  4darray sel_a(styr-3,YrMax,1,Nfleet,1,gender,0,nages)
  vector sel(1,nlength)  //  used to multiply by ALK

  4darray retain_a(styr-3,YrMax,1,Nfleet,1,gender,0,nages)
  4darray discmort_a(styr-3,YrMax,1,Nfleet,1,gender,0,nages)
  4darray discmort2_a(styr-3,YrMax,1,Nfleet,1,gender,0,nages)
  4darray sel_a_r(styr-3,YrMax,1,Nfleet,1,gender,0,nages)


!!//  SS_Label_Info_5.1.6 #Create tag parameters and associated arrays
  matrix TG_alive(1,pop,1,gmorph)
  matrix TG_alive_temp(1,pop,1,gmorph)
  3darray TG_recap_exp(1,N_TG2,0,TG_endtime,0,Nfleet)   //  do not need to store POP index because each fleet is in just one area
  vector TG_like1(1,N_TG2)
  vector TG_like2(1,N_TG2)
  number overdisp     // overdispersion

 LOCAL_CALCS
  k=Do_TG*(3*N_TG+2*Nfleet);
 END_CALCS

  init_bounded_number_vector TG_parm(1,k,TG_parm_LO,TG_parm_HI,TG_parm_PH);

 LOCAL_CALCS
  if(Do_Forecast>0)
  {k=TimeMax_Fcast_std+1;}
  else
  {k=TimeMax+nseas;}
 END_CALCS

!!//  SS_Label_Info_5.1.7 #Create arrays for storing derived selectivity quantities for use in mortality calculations
  4darray fish_body_wt(styr-3*nseas,k,1,gmorph,1,Nfleet,0,nages);  // wt (adjusted for size selex)
  4darray sel_al_1(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected * wt
  4darray sel_al_2(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected * retained * wt
  4darray sel_al_3(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected numbers
  4darray sel_al_4(1,nseas,1,gmorph,1,Nfleet,0,nages);  // selected * retained numbers
  4darray deadfish(1,nseas,1,gmorph,1,Nfleet,0,nages);  // sel * (retain + (1-retain)*discmort)
  4darray deadfish_B(1,nseas,1,gmorph,1,Nfleet,0,nages);  // sel * (retain + (1-retain)*discmort) * wt

  4darray save_sel_fec(styr-3*nseas,TimeMax_Fcast_std+nseas,1,gmorph,0,Nfleet,0,nages)  //  save sel_al_3 (Asel_2) and save fecundity for output;  +nseas covers no forecast setups

  4darray Sel_for_tag(TG_timestart*Do_TG,TimeMax*Do_TG,1,gmorph*Do_TG,1,Nfleet,0,nages)
  vector TG_report(1,Nfleet*Do_TG);
  vector TG_rep_decay(1,Nfleet*Do_TG);

  3darray save_sp_len(styr,YrMax,1,2*Nfleet,1,50);     // use to output selex parm values after adjustment

  3darray exp_l(1,Nfleet,1,Nobs_l,1,nlen_bin2)
  matrix neff_l(1,Nfleet,1,Nobs_l)
  vector tempvec_l(1,nlength);
  vector exp_l_temp(1,nlength2);
  vector exp_truea_ret(0,nages2);
  vector exp_l_temp_ret(1,nlength2);     // retained lengthcomp
  vector exp_l_temp_dat(1,nlen_bin2);
//  vector offset_l(1,Nfleet) // Compute OFFSET for multinomial (i.e, value for the multinonial function
  matrix length_like(1,Nfleet,1,Nobs_l)  // likelihood of the length-frequency data
  vector length_like_tot(1,Nfleet)  // likelihood of the length-frequency data
  matrix SzFreq_exp(1,SzFreq_totobs,1,SzFreq_Setup2);
  vector SzFreq_like(1,SzFreq_N_Like)
  3darray exp_a(1,Nfleet,1,Nobs_a,1,n_abins2)
  vector exp_a_temp(1,n_abins2)
  vector tempvec_a(0,nages)
  vector agetemp(0,nages2)
  matrix neff_a(1,Nfleet,1,Nobs_a)
  matrix age_like(1,Nfleet,1,Nobs_a)  // likelihood of the age-frequency data
  vector age_like_tot(1,Nfleet)  // likelihood of the age-frequency data
  vector sizeage_like(1,Nfleet)  // likelihood of the age-frequency data
  3darray exp_ms(1,Nfleet,1,Nobs_ms,1,n_abins2)
  3darray exp_ms_sq(1,Nfleet,1,Nobs_ms,1,n_abins2)

  number Morphcomp_like
  number equ_catch_like
  vector catch_like(1,Nfleet)
  number recr_like
  number Fcast_recr_like
  number parm_like
  vector MGparm_dev_like(1,N_MGparm_dev)
  vector selparm_dev_like(1,N_selparm_dev)
  number CrashPen
  number SoftBoundPen
  number Equ_penalty
  number F_ballpark_like

  number R1
  number R1_exp
  number t1
  number t2
  number temp
  number temp1
  number temp2
  number temp3
  number temp4
  number join1
  number join2
  number join3
  number upselex
  number downselex
  number peak
  number peak2
  number point1
  number point2
  number point3
  number point4
  number timing
  number equ_Recr
  number equ_F_std

!!//  SS_Label_Info_5.1.8 #Create matrix called smry to store derived quantities of interest
  matrix Smry_Table(styr-3,YrMax,1,20+2*gmorph);
  // 1=totbio, 2=smrybio, 3=smrynum, 4=enc_catch, 5=dead_catch, 6=ret_catch, 7=spbio, 8=recruit,
  // 9=equ_totbio, 10=equ_smrybio, 11=equ_SPB_virgin, 12=equ_S1, 13=Gentime, 14=YPR, 15=meanage_spawners, 16=meanage_smrynums, 17=meanage_catch
  // 18, 19, 20  not used
  // 21+cumF-bymorph, maxF-by morph

  matrix env_data(styr-1,YrMax,-4,N_envvar)
  matrix TG_save(1,N_TG,1,3+TG_endtime)

!!//  SS_Label_Info_5.2 #Create sdreport vectors
  sdreport_vector SPB_std(1,N_STD_Yr);
  sdreport_vector recr_std(1,N_STD_Yr);
  sdreport_vector SPR_std(1,N_STD_Yr_Ofish);
  sdreport_vector F_std(1,N_STD_Yr_F);
  sdreport_vector depletion(1,N_STD_Yr_Dep);
  sdreport_vector Mgmt_quant(1,N_STD_Mgmt_Quant)
  sdreport_vector Extra_Std(1,Extra_Std_N)

!!//  SS_Label_Info_5.3 #Create log-Likelihood vectors
  vector MGparm_Like(1,N_MGparm2)
  vector init_F_Like(1,Nfleet)
  vector Q_parm_Like(1,Q_Npar)
  vector selparm_Like(1,N_selparm2)
  vector SR_parm_Like(1,N_SRparm2)
  vector recdev_cycle_Like(1,recdev_cycle)
  !! k=Do_TG*(3*N_TG+2*Nfleet);
  vector TG_parm_Like(1,k);

!!//  SS_Label_Info_5.4  #Define objective function
  objective_function_value obj_fun
  number last_objfun
  vector phase_output(1,max_phase+1)
  !!cout<<" end of parameter section "<<endl;
  !!echoinput<<"end of parameter section"<<endl;
//  }  // end of parameter section
