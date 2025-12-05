// lib/data/questions_list.dart
import '../models/questions_model.dart';
import '../screens/patient_form.dart' show Dependency;


final List<Question> questions = [
  Question(
    key: 'patientMaritalstatus',
    label: 'Marital Status of the Patient',
    type: QuestionType.radio,
    options: ['Single', 'Married'],
    required: true,
  ),
  Question(
    key: 'resEdulvlpatient',
    label: 'Education Level of the Patient',
    type: QuestionType.radio,
    options: ['Literate', 'Illiterate'],
    required: true,
  ),
  Question(
    key: 'resustandinglevelpatient',
    label: 'Understanding level of the Patient',
    type: QuestionType.radio,
    options: ['Very Good', 'Good', 'Average', 'Below Average'],
    required: true,
  ),
  Question(
    key: 'respctname',
    label: 'Name of Primary care taker',
    type: QuestionType.text,
    required: true,
  ),
  Question(
    key: 'usermobile',
    label: 'Primary care taker contact no',
    type: QuestionType.number,
    required: true,
  ),
  Question(
    key: 'respctrelationship',
    label: 'Primary care taker relationship',
    type: QuestionType.dropDown,
    options: [
      "Father",
      "Mother",
      "Son",
      "Son in Law",
      "Daughter in Law",
      "Daughter",
      "Husband",
      "Wife",
      "Brother",
      "Sister",
      "Grandfather",
      "Grandmother",
      "Grandson",
      "Uncle",
      "Aunt",
      "Nephew",
      "Niece",
      "Cousins",
      "Others",
    ],
    required: true,
  ),
  Question(
    key: 'resedulevelpct',
    label: 'Education Level of the Pt.Attender',
    type: QuestionType.radio,
    options: ['Literate', 'Illiterate'],
    required: true,
  ),
  Question(
    key: 'resundlevelpct',
    label: 'Understanding Level of the Pt.Attender',
    type: QuestionType.radio,
    options: ['very Good', 'Good', 'Average', 'Below Average'],
    required: true,
  ),
  Question(
    key: 'rescontpdccall',
    label: 'Whom to contact for PDC call',
    type: QuestionType.radio,
    options: ['Pt.Attender', 'Patient'],
    required: true,
  ),
  Question(
    key: 'reslanguagewanted',
    label: 'Language Preferred',
    type: QuestionType.radio,
    options: ['Tamil', 'English', 'Both'],
    required: true,
  ),
  Question(
    key: 'resdischargetype',
    label: 'Type Of Discharge',
    type: QuestionType.radio,
    options: ['Planned', 'Transfer', 'Referral'],
    required: true,
  ),

  // condition based questions starts from here
  Question(
    key: 'psd',
    label: 'Patient Status during Discharge: Stable',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'resambulantorbedridden',
    label: 'Ambulant or Bed ridden',
    type: QuestionType.radio,
    options: ['Ambulant', 'Bed ridden'],
    required: true,
  ),

  Question(
    key: 'comor',
    label: 'Co-Morbidities',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'Co-Morbidities',
    label: 'Co-Morbidities (select all that apply)',
    type: QuestionType.checkBox,
    options: [
      'DM',
      'HTN',
      'CKD',
      'CAD',
      'CVA',
      'Br.Asthma',
      'Thyroidism',
      'Anaemia',
      'Others',
      //   rescomoribtesreason type for others
    ],
    required: true,
  ),

  Question(
    key: 'distubesdrains',
    label: 'Discharge with tubes and drainages',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'Discharged-with-tubes-and-drainages',
    label: 'Tubes and drainages',
    type: QuestionType.checkBox,
    options: [
      'Ryles tube',
      'Urinary catheter',
      'PCNL catheter',
      'SPC catheter',
      'DJ Stent',
      'Drain Tubes',
      'Others',
      //   restubesdrainagesreason type for others
    ],
    required: true,
  ),

  Question(
    key: 'diswithosotomy',
    label: 'Discharge with Ostomy',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'Ostomy',
    label: 'Ostomy',
    type: QuestionType.checkBox,
    options: [
      'Tracheostomy',
      'Jejunostomy',
      'Colostomy',
      'Others',
      //   resosotomyreason type for others
    ],
    required: true,
  ),

  Question(
    key: 'diswithhai',
    label: 'Discharge with HAI',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'HAI',
    label: 'HAI',
    type: QuestionType.checkBox,
    options: [
      'Phlebhitis',
      'Cauti',
      'SSI',
      'VAP',
      'Clabsi',
      'Others',
      //   reshaidreason type for others
    ],
    required: true,
  ),

  Question(
    key: 'diswithlatinj',
    label: 'Discharge with Iatrogenic Injuries',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'IatrogenicInjuries',
    label: 'Iatrogenic Injuries',
    type: QuestionType.checkBox,
    options: [
      'Pressure Injury',
      'Ryles Tube',
      'Plasters',
      'Masks',
      'Stockings',
      'ECG Leads',
      'POP',
      'Others',
      //   reslatrogenicreasons type for others
    ],
    required: true,
  ),

  Question(
    key: 'compduringdis',
    label: 'Complications During Discharge',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'Complications',
    label: 'Complications',
    type: QuestionType.checkBox,
    options: [
      'Anesthesia Related',
      'ADR/ADE',
      'Sore Throat',
      'Hoarseness of voice',
      'Others',
      //   reslatrogenicreasons type for others
    ],
    required: true,
  ),

  Question(
    key: 'allergy',
    label: 'Allergic',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'resfood',
    label: 'Food',
    type: QuestionType.text,
    required: true,
  ),
  Question(
    key: 'resreaction',
    label: 'Reaction',
    type: QuestionType.text,
    required: true,
  ),
  Question(
    key: 'resdrug',
    label: 'Drug',
    type: QuestionType.text,
    required: true,
  ),
  Question(
    key: 'resdrugreaction',
    label: 'Reaction',
    type: QuestionType.text,
    required: true,
  ),

  Question(
    key: 'sursite',
    label: 'Surgical Site',
    type: QuestionType.radio,
    options: ['Healed', 'Infected','NA'],
    required: true,
  ),
  Question(
    key: 'Complaints',
    label: 'Complaints',
    type: QuestionType.checkBox,
    options: ['Pain', 'Swelling', 'Redness'],
    required: true,
  ),

  Question(
    key: 'reshealthedu',
    label: 'Health Education Given On',
    type: QuestionType.radio,
    options: ['Yes', 'No'],
    required: true,
  ),
  Question(
    key: 'Instructions',
    label: 'Instructions',
    type: QuestionType.checkBox,
    options: [
      'Personal Hygiene',
      'Diet',
      'Activities',
      'Wound Care',
      'Advice Medicine',
      'Review follow up',
    ],
    required: true,
  ),

  // static questions
  Question(
    key: 'patientpresentdiet',
    label: 'Patient present diet',
    type: QuestionType.radio,
    options: ['Normal', 'Liquid','Semisolid','Soft','Diabetic','Therapeutic'],
    required: true,
  ),

  Question(
    key: 'resbowelrhabbits',
    label: 'Bowel Habits',
    type: QuestionType.radio,
    options:['Normal', 'Constipation','Loose Tools'],
    required: true,
  ),

  Question(
    key: 'Reasonbladderhabbits',
    label: 'Bladder Habits',
    type: QuestionType.radio,
    options:['Normal', 'Retention','Incontinence'],
    required: true,
  ),

  Question(
    key: 'resultsleep',
    label: 'Sleep',
    type: QuestionType.radio,
    options:['Normal', 'Disturbed'],
    required: true,
  ),

];

final List<Dependency> deps = [
  Dependency(
    controllerKey: 'psd',
    dependentKey: 'resambulantorbedridden',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'comor',
    dependentKey: 'Co-Morbidities',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'distubesdrains',
    dependentKey: 'Discharged-with-tubes-and-drainages',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'diswithosotomy',
    dependentKey: 'Ostomy',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'diswithhai',
    dependentKey: 'HAI',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'diswithlatinj',
    dependentKey: 'IatrogenicInjuries',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'compdurdis',
    dependentKey: '_myActivities6',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'compduringdis',
    dependentKey: 'Complications',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'allergy',
    dependentKey: 'resfood',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'allergy',
    dependentKey: 'resreaction',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'allergy',
    dependentKey: 'resdrug',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'allergy',
    dependentKey: 'resdrugreaction',
    showWhenValues: ['Yes'],
  ),
  Dependency(
    controllerKey: 'sursite',
    dependentKey: 'Complaints',
    showWhenValues: ['Infected'],
  ),
  Dependency(
    controllerKey: 'reshealthedu',
    dependentKey: 'Instructions',
    showWhenValues: ['Yes'],
  ),

];
