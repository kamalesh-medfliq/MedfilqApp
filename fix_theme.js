const fs = require('fs');
const path = require('path');

const files = [
  'lib/features/patients/presentation/screens/patient_profile_screen.dart',
  'lib/features/patients/presentation/screens/patients_screen.dart',
  'lib/features/patients/presentation/widgets/patient_form_modal.dart'
];

files.forEach(file => {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/AppTheme\.primaryColor/g, 'AppTheme.primaryOrange');
  content = content.replace(/AppTheme\.darkCard/g, 'const Color(0xFF262220)');
  content = content.replace(/AppTheme\.darkSurface/g, 'const Color(0xFF1E1A18)');
  content = content.replace(/\.withOpacity\(/g, '.withValues(alpha: ');
  fs.writeFileSync(file, content);
  console.log(`Updated ${file}`);
});
