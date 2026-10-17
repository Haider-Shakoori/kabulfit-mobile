// Original measurement steps, photos and tutorial URLs are mirrored from
// kabulfit Laravel resources/views/content/pages/measurement-guide.blade.php
// and database/data/base44_measurement_guide_videos.json.
// Do not silently replace or invent measurement media.
class KabulFitGuideStep {
  const KabulFitGuideStep(this.id, this.image, this.en, this.fa, this.ps, this.videoEn, this.videoFa, this.videoPs);
  final String id;
  final String image;
  final String en;
  final String fa;
  final String ps;
  final String videoEn;
  final String videoFa;
  final String videoPs;
  String title(String locale) => switch (locale) { 'fa' => fa, 'ps' => ps, _ => en };
  String video(String locale) => switch (locale) { 'fa' => videoFa.isEmpty ? videoEn : videoFa, 'ps' => videoPs.isEmpty ? videoEn : videoPs, _ => videoEn };
  String get imageUrl => 'https://kabulfit.businessos.af/images/kabulfit-base44/source/$image';
}

abstract final class OriginalKabulFitMeasurementGuide {
  static const male = <KabulFitGuideStep>[
    KabulFitGuideStep("neck", "8a81aa932_neckmeasure.png", "Neck", "یخن", "غاړه", "https://www.youtube.com/embed/jelx_la9r3U?si=k_YqVZobuJ6xg_bH", "https://www.youtube.com/embed/VtD-MK6UAXc?si=Ptbfp4p03Ai7FSa_", "https://www.youtube.com/embed/FbgaYZoGp_Q?si=E43TPfSOppH5v2Zs"),
    KabulFitGuideStep("shoulder", "12e22a9d0_shuldermeasure.png", "Shoulder", "شانه", "اوږه", "https://www.youtube.com/embed/agpR2I79rUA?si=rdnqGd8HTqLql2uf", "https://www.youtube.com/embed/dTq5nZQl-tU?si=d03J9Ct6w7rjWGzX", "https://www.youtube.com/embed/WahJ7uTOEC8?si=3riCJ6KUKPaTJBnk"),
    KabulFitGuideStep("underarm", "cfa4c252f_UnderArm.png", "Underarm", "زیر بغل", "بغل", "https://www.youtube.com/embed/oxanXwFuebA?si=YQa7kkMa_TU7zYiy", "https://www.youtube.com/embed/ipbRnYCaCfM?si=rYDI17fdx-8qQp8g", "https://www.youtube.com/embed/M8kmxezT0l8?si=M4evqeiX8Zbjush2"),
    KabulFitGuideStep("waist", "bac309e26_2.png", "Waist", "کمر", "ملا", "https://www.youtube.com/embed/G-ow1WM_RP0?si=Mxpv_YDZFX03J--W", "https://www.youtube.com/embed/GWyv03z5EZA?si=8dYBkZQvg_vCy3q7", "https://www.youtube.com/embed/JDiUAFj2N88?si=hi9-IDu1ypRy_qwm"),
    KabulFitGuideStep("arm_length", "6eca0d92f_SleeveLength.png", "Sleeve Length", "طول آستین", "لستوڼی", "https://www.youtube.com/embed/KlAQQnWrOTk?si=6djbiKhoGIwHFIdD", "https://www.youtube.com/embed/NrJ67Ir6Gf0?si=d_Szk9SRWnEDziHh", "https://www.youtube.com/embed/QFCZloZhsm0?si=pdL8J2xv2BO6CcH3"),
    KabulFitGuideStep("bicep", "b54401e30_Bicep.png", "Bicep", "بازو", "مټ/بازو", "https://www.youtube.com/embed/UsJATb6LMgk?si=T8p2bhvaKT4HT2Ix", "https://www.youtube.com/embed/qKfm26AvBf4?si=r1k7_wPOIwkwaLDr", "https://www.youtube.com/embed/JxrQjVKY7-k?si=rDLGMvyTmmDw-vfu"),
    KabulFitGuideStep("sleeve_opening", "63998adda_wrist.png", "Wrist/Sleeve Opening", "دهن آستین", "د لستوڼی خوله", "https://www.youtube.com/embed/_Ncy3duHGLU?si=TnwIsDOvPXSujIlm", "https://www.youtube.com/embed/0SNt3NOzNFE?si=ZeSidx8xKPIgqf-I", "https://www.youtube.com/embed/rrgRqpzfueA?si=jhVHmXC2tpeLFSk0"),
    KabulFitGuideStep("full_dress_length", "e9d011494_DressLength1.png", "Full Dress Length", "قد کامل پیراهن", "د بشپږ کمیس اوږدوالی", "https://www.youtube.com/embed/BDO-txUaB4Y?si=mb492Krq2KNa5bld", "https://www.youtube.com/embed/KjWQ4gYhIA0?si=dGqTxeGoqC1GPmdd", "https://www.youtube.com/embed/CQb3SrnN0JA?si=ybOVXjksxtlJ6jMN"),
    KabulFitGuideStep("dress_hem_width", "47f29dd78_DressHemWidth.png", "Dress Hem Width", "عرض دامن", "د لمنی بر", "https://www.youtube.com/embed/QPoOsDxAUw0?si=DVSPGpCHahe1H6t3", "https://www.youtube.com/embed/Bedm0AyNSrA?si=iOPH1_KOO3J46Weo", "https://www.youtube.com/embed/2CMk07WI2Hs?si=vgyK6ukAvJH6JjUR"),
    KabulFitGuideStep("tunban_length", "83ddd063b_TrouserLength.png", "Trouser Length", "تنبان", "پرتوګ", "https://www.youtube.com/embed/SaYMzSgBDdE?si=fcLyn8a7uIPHUg5V", "https://www.youtube.com/embed/LVjo8MpOSxs?si=ejh8mAi0cb7U9kL-", "https://www.youtube.com/embed/ZKczpK-ovPM?si=vHyo-NaiU-hv_W6F"),
    KabulFitGuideStep("trouser_leg_opening", "87a024cde_LegOpening.png", "Trouser Leg Opening", "پاچه", "پایڅه", "https://www.youtube.com/embed/qG4aY4my27s?si=SAxO7-j9wb6kOAww", "https://www.youtube.com/embed/EYsoZvZe_VU?si=T_Mr8J6nXcvs-Q95", "https://www.youtube.com/embed/8kHn1ZNyZLE?si=W2TwuDhFQSkxQVVq"),
  ];
  static const female = <KabulFitGuideStep>[
    KabulFitGuideStep("neck", "e2ac85db0_Neck.png", "Neck", "یخن", "غاړه", "https://www.youtube.com/embed/bCuamdz9AZ8?si=JcJgaKhfrrsp0lph", "https://www.youtube.com/embed/l1r9Awl-K9Q?si=TqGdAjkumjZy69IA", "https://www.youtube.com/embed/nxm5InaA0-I?si=wYiuwNEVWkdvzFN1"),
    KabulFitGuideStep("shoulder", "b5e2b7848_Shoulder.png", "Shoulder", "شانه", "اوږه", "https://www.youtube.com/embed/Yi2N9BKafTo?si=JE4OGhRmUvlYYqL4", "https://www.youtube.com/embed/f6CYr4YdGcY?si=TmOU8O7nV4ENNRNG", "https://www.youtube.com/embed/0LZx7bkV5jQ?si=BhobvWDudK64sJcK"),
    KabulFitGuideStep("underarm", "5f0b6db2c_Underarm.png", "Underarm", "زیر بغل", "بغل", "https://www.youtube.com/embed/sfq_okW5idI?si=XS1qsJ93ia8xInUJ", "https://www.youtube.com/embed/rBRsBPh9bDE?si=tLVDExx6H9KXxsom", "https://www.youtube.com/embed/XoWRld1WSy8?si=-m0kUhPkaNI0FRrZ"),
    KabulFitGuideStep("chest", "0040f6f9d_Bust.png", "Bust/Chest", "سینه", "ځیګر", "https://www.youtube.com/embed/SkQEV1tpFZk?si=fKgc0vxNNc1uPOsX", "https://www.youtube.com/embed/u3gyKeZ2jFg?si=9QPxIvC1nAEGt5Oi", "https://www.youtube.com/embed/Ify8jiTzq8Q?si=FpNZ3PF8NG1oZVxW"),
    KabulFitGuideStep("waist", "750a713eb_Waist.png", "Waist", "کمر", "ملا", "https://www.youtube.com/embed/LbekfsIBgmY?si=QCse2Fc25J1QNZWE", "https://www.youtube.com/embed/v0QbzI_CGnA?si=IqDCX4n9KSKLz5V8", "https://www.youtube.com/embed/zSguDT9k9U8?si=ta47z-_HOkafLJN-"),
    KabulFitGuideStep("hip", "d2aabc8ae_Hips.png", "Hips", "سرین/باسن", "ورون/سرین", "https://www.youtube.com/embed/HZsPHjRqCzw?si=6Yw045utHQa0R9oR", "https://www.youtube.com/embed/mZj2EF2lcN8?si=05_PZNvQBO7TVWAU", "https://www.youtube.com/embed/-kjAdSXe3Uk?si=vNWOrILOUabBT7Uz"),
    KabulFitGuideStep("arm_length", "478755a70_SleeveLength.png", "Sleeve Length", "طول آستین", "لستوڼی", "https://www.youtube.com/embed/BDO7DFI9xfU?si=pZbxw9uePz497DZR", "https://www.youtube.com/embed/Gyjy-qtqESI?si=hW4MqYSqm99gAkec", "https://www.youtube.com/embed/Jw4FosCHfeQ?si=iqGW_IkArBUUkSUV"),
    KabulFitGuideStep("armhole", "2183cd7d2_Armhole1.png", "Armhole", "دور حلقه آستین", "د لستوڼی حلقه", "https://www.youtube.com/embed/pqZCCKsAvhU?si=jXgvEuL6m03nL-7p", "https://www.youtube.com/embed/JwhjTqTdpo8?si=nwp0U1UZLvwVEDLr", "https://www.youtube.com/embed/_CPXFkO-kOM?si=aayyaLIbIdTmjCyf"),
    KabulFitGuideStep("bicep", "316edb797_Bicep.png", "Bicep", "بازو", "مټ/بازو", "https://www.youtube.com/embed/ztWdVoWROHo?si=9fC4B65OwWG2iUMZ", "https://www.youtube.com/embed/IdSg4ah15Vk?si=SHsUEF9RSKya2LpO", "https://www.youtube.com/embed/C230LO0EJgE?si=9Ya54yJVyzLXCf-F"),
    KabulFitGuideStep("sleeve_opening", "b56615645_Wrist.png", "Wrist/Sleeve Opening", "دهن آستین", "د لستوڼی خوله", "https://www.youtube.com/embed/w20m1l7r-a4?si=3fYZEoTnAyA0tr5r", "https://www.youtube.com/embed/QYRBIfTY_es?si=LcBQxwKq74u9Kdsj", "https://www.youtube.com/embed/YW84YmctV1s?si=utRZEySaueeSH4TH"),
    KabulFitGuideStep("full_dress_length", "01fee21b7_DressFullLength.png", "Full Dress Length", "قد کامل پیراهن", "د بشپږ کمیس اوږدوالی", "https://www.youtube.com/embed/YstX8bIyxtQ?si=dIR-5Gi11ghnUwBp", "https://www.youtube.com/embed/WCvZXImGAzo?si=YoSIHKQsQ_r6raX0", "https://www.youtube.com/embed/SEUyHLVtVU0?si=KFrIwG6pOMHRyEzO"),
    KabulFitGuideStep("tunban_length", "ca7c52ac3_TrouserLength.png", "Trouser Length", "تنبان", "پرتوګ", "https://www.youtube.com/embed/5n1IF0e3tuM?si=VWLupJhEkfr_fk_x", "https://www.youtube.com/embed/wQiofUk_qc0?si=QFuGSK9TKnnPmLZp", "https://www.youtube.com/embed/IG5jrAzwMEA?si=L9INJJFq_jIMeLna"),
    KabulFitGuideStep("kameez_length", "53b508b4f_DressTopLength.png", "Dress Top Length", "قد بالاتنه", "ګنډ/بالاتنه", "https://www.youtube.com/embed/gywXqSM_fmE?si=y078MTWkZ_5ZRO6o", "https://www.youtube.com/embed/MwUIqwpy92A?si=2YaAaYrGjClTlsuG", "https://www.youtube.com/embed/3PdpFCLJfcY?si=7_z3qxAT5sMcVqRF"),
    KabulFitGuideStep("skirt_length", "177acd4f8_SkirtLength.png", "Skirt Length", "قد دامن", "د لمنی اوږدوالی", "https://www.youtube.com/embed/uB1gliLgjVw?si=uB9k51YIqhax2CQi", "https://www.youtube.com/embed/lqpW_ndQs2Q?si=fxumsAKku7S4MPHj", "https://www.youtube.com/embed/p4DYEPpD-kE?si=46cwVxrpqq2QSubY"),
    KabulFitGuideStep("bust_point_to_bust_point", "47616e12d_BustToBust.png", "Bust Point to Bust Point", "فاصله سینه", "د ځیګر فاصله", "https://www.youtube.com/embed/M7gECCY578w?si=XTccwADiufRLBjYg", "https://www.youtube.com/embed/Fe6VdoMc_2Q?si=frbG29uTnRCdisxG", "https://www.youtube.com/embed/spQtbhOROK0?si=72qjKIbDerotbnm2"),
    KabulFitGuideStep("front_neck_drop", "d99476581_FrontNeckDrop.png", "Front Neck Drop", "افتادگی یخن جلو", "د مخکې غاړې ښکته والی", "https://www.youtube.com/embed/eWKMVD4tGHY?si=k2LIAhWCbdA_-32P", "https://www.youtube.com/embed/vLDkLD6F2b4?si=IjpAdrtkubdb9SGy", "https://www.youtube.com/embed/uDR9VbvvSVE?si=DyiTuNviAWE2lkg3"),
    KabulFitGuideStep("wrist", "63492a53b_BackNeckDrop.png", "Back Neck Drop", "افتادگی یخن عقب", "د شا غاړې ښکته والی", "https://www.youtube.com/embed/KT5bhTDpaM0?si=4aVlVRIQ94POfqKb", "https://www.youtube.com/embed/NtC58bA4xHM?si=CX1ECj1_xO6VUAps", "https://www.youtube.com/embed/UIpjxmtPOn8?si=lt0mDE1qbDrexFZd"),
  ];
}
