module.exports = {
  onPreBuild: async ({ utils }) => {
    console.log('🚀 Setting up Flutter...');
    
    // Install Flutter
    await utils.run.command('git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter');
    
    // Set PATH
    process.env.PATH = `/opt/buildhome/flutter/bin:/opt/buildhome/flutter/bin/cache/dart-sdk/bin:${process.env.PATH}`;
    
    // Verify installation
    await utils.run.command('/opt/buildhome/flutter/bin/flutter --version');
  },
  onBuild: async ({ utils }) => {
    console.log('📥 Installing dependencies...');
    await utils.run.command('/opt/buildhome/flutter/bin/flutter pub get');
    
    console.log('🏗️ Building web release...');
    await utils.run.command('/opt/buildhome/flutter/bin/flutter build web --release');
  }
};