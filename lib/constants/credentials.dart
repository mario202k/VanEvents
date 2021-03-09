const placesApiKey = 'AIzaSyANu2dlwJvQXKqZBKCbHfvtOBkhlSOIGg8'; //google
const pkTest = 'pk_test_gPlqnEqiVydntTBkyFzc4aUb001o1vGwb6'; //Stripe
const appId = 'caf08851b010462981e8c3b856d9df8a';
const giphyApiKey = 'nZXOSODAIyJlsmNBMXzz55JvV5f8kd0D';
const agoraKey = 'caf08851b010462981e8c3b856d9df8a';
const regExpNom =
    r'^[a-zA-ZáàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ\-. ]{2,60}$';
const regExpMDP = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d.*)[a-zA-Z0-9\S]{8,15}$';

const List<Map<String,dynamic>> dummyUser = [
  {
    "nom": "Akalab Benshasa",
    "imageUrl":
        "https://i.pinimg.com/originals/74/92/03/7492036a71a7289aa34e1b445489be97.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Nicolas Frey",
    "imageUrl":
    "https://archzine.fr/wp-content/uploads/2018/01/comment-bien-tailler-sa-barbe-au-rasoir-rasage-en-pointe-barbes.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Satya Oblet",
    "imageUrl":
    "https://i.pinimg.com/originals/8a/8f/83/8a8f83accfdb7640b52188016f42a1a8.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Amaury Caouën",
    "imageUrl":
    "https://lvdneng.rosselcdn.net/sites/default/files/dpistyles_v2/ena_16_9_extra_big/2020/02/11/node_708653/45358063/public/2020/02/11/B9722551600Z.1_20200211152415_000%2BGUQFGFC37.1-0.jpg?itok=bKgKWReX1581437606",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Mizushima Hiro",
    "imageUrl":
    "https://i.pinimg.com/originals/a5/62/e1/a562e1aaf1c4a399ab24d9a022f2c308.png",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Mamoudou Kirikou",
    "imageUrl":
    "https://i.pinimg.com/474x/e3/36/7b/e3367b39f28523af81d2f35949a4775d.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Mohammed Azziz",
    "imageUrl":
    "https://i.pinimg.com/564x/73/0d/77/730d772eaae402cbf45ff2ce1c6117f8.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Marlon Teixeira",
    "imageUrl":
    "https://i.pinimg.com/originals/1a/05/a4/1a05a4b95abf522152db54e81b3410be.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Will Brayton",
    "imageUrl":
    "https://i.pinimg.com/originals/b2/ed/e0/b2ede0736a95bd1fe45909fe0d985dad.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "David Rivière",
    "imageUrl":
    "https://i.pinimg.com/736x/e5/ce/85/e5ce852896e71b1dca6a78bbfb500627.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Emily Carlton",
    "imageUrl":
    "https://us.123rf.com/450wm/annanahabed/annanahabed1705/annanahabed170500010/77496166-gros-plan-portrait-de-belle-jeune-femme-de-25-30-ans-avec-maquillage-professionnel-v%C3%AAtu-d-une-veste.jpg?ver=6",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Yulia Kozlova",
    "imageUrl":
    "https://lh3.googleusercontent.com/proxy/fsBgHZ0VMalb03Qk9pqRdB8YBIrzbP1mFsnEcXX7njW5_mRrul73XmrXg18h7hcfq_wdJn2Wemn4-43OnnovM6uEI_MB1MWoVHyfYU9nBnyesrkIrcgKO_gPy4a61fJZj6AphizrUhf2iBdOw3E2G6wz2L8luAW1Z-S-7a_N",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Tatiana Galva",
    "imageUrl":
    "https://angelique-delahaye.eu/wp-content/uploads/2555/site-de-rencontre-amoureuse-gratuit-africain-5e4604a89146f.png",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Gwedoline Dado",
    "imageUrl":
    "https://image.freepik.com/photos-gratuite/jeune-femme-noire-coiffure-afro-souriant_3179-181.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Arya RAMTALI",
    "imageUrl":
    "https://i.pinimg.com/originals/1f/87/af/1f87afd938606a05145ac3a10e4d3331.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Mei Ying",
    "imageUrl":
    "https://i.pinimg.com/474x/7d/95/13/7d9513888b0a45691088db00724a02cc.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Angélica Flavia",
    "imageUrl":
    "https://i.pinimg.com/originals/00/31/2c/00312c99df331b54d59a364729bc56ab.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Stéphanie Bertrand",
    "imageUrl":
    "https://elybeautyhair.files.wordpress.com/2014/11/belle-peau-2.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Délphine Jacob",
    "imageUrl":
    "https://image.freepik.com/photos-gratuite/portrait-femme-metisse-peau-foncee-ravie-heureux-cheveux-crepus-touffus-se-sent-detendu-comme-est-assis-canape-confortable-contre-mur-rose_273609-3221.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
  {
    "nom": "Stella Dasilva",
    "imageUrl":
    "https://i.pinimg.com/474x/d1/fc/12/d1fc12c25c15f65c97522570d5c16fdf.jpg",
    "typeDeCompte": "TypeOfAccount.userNormal",
    "email": "mario202k@hotmail.fr"
  },
];
