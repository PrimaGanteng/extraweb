const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Read .env.local file
const envPath = path.join(__dirname, '.env.local');
let supabaseUrl, supabaseAnonKey;

try {
  const envContent = fs.readFileSync(envPath, 'utf8');
  const lines = envContent.split('\n');
  for (const line of lines) {
    const [key, value] = line.split('=');
    if (key === 'NEXT_PUBLIC_SUPABASE_URL') {
      supabaseUrl = value;
    } else if (key === 'NEXT_PUBLIC_SUPABASE_ANON_KEY') {
      supabaseAnonKey = value;
    }
  }
} catch (err) {
  console.error('Error reading .env.local:', err.message);
  process.exit(1);
}

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables in .env.local');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function checkAdminUser() {
  try {
    console.log('Checking for admin user: primacom5551@gmail.com');

    // Check auth user first
    console.log('Checking auth user...');
    const { data: authUser, error: authError } = await supabase.auth.getUser();
    if (authError) {
      console.log('No authenticated user. Checking by email...');
    } else {
      console.log('Auth user ID:', authUser.user?.id);
    }

    // Try to query by email (this might fail due to RLS)
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', 'primacom5551@gmail.com');

    if (error) {
      console.error('Error querying by email:', error);
      console.log('This is likely due to RLS policies blocking the query.');
      console.log('You need to run SQL queries directly in Supabase SQL Editor.');
      console.log('');
      console.log('Run these SQL commands:');
      console.log('');
      console.log('1. Check if user exists in auth.users:');
      console.log('SELECT id, email FROM auth.users WHERE email = \'primacom5551@gmail.com\';');
      console.log('');
      console.log('2. Check if user exists in users table:');
      console.log('SELECT * FROM users WHERE email = \'primacom5551@gmail.com\';');
      console.log('');
      console.log('3. If user exists in auth.users but not in users, insert:');
      console.log('INSERT INTO users (id, email, role, username)');
      console.log('SELECT id, email, \'admin\', \'admin\'');
      console.log('FROM auth.users');
      console.log('WHERE email = \'primacom5551@gmail.com\';');
      console.log('');
      console.log('4. If user exists but role is not admin, update:');
      console.log('UPDATE users SET role = \'admin\' WHERE email = \'primacom5551@gmail.com\';');
      return;
    }

    if (data && data.length > 0) {
      console.log('User found in users table:', data[0]);
      console.log('Role:', data[0].role);
      if (data[0].role !== 'admin') {
        console.log('User role is not admin. You need to update it.');
        console.log('Run this SQL:');
        console.log(`UPDATE users SET role = 'admin' WHERE email = 'primacom5551@gmail.com';`);
      } else {
        console.log('User has admin role. The 500 error might be due to other issues.');
        console.log('Check Supabase logs for more details on the 500 error.');
      }
    } else {
      console.log('User not found in users table.');
      console.log('You need to insert the admin user. Run this SQL:');
      console.log('INSERT INTO users (id, email, role, username)');
      console.log('SELECT id, email, \'admin\', \'admin\'');
      console.log('FROM auth.users');
      console.log('WHERE email = \'primacom5551@gmail.com\';');
    }
  } catch (err) {
    console.error('Unexpected error:', err);
  }
}

checkAdminUser();
