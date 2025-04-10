require 'sinatra'
require 'fileutils'
require 'open3'

set :bind, '0.0.0.0'
set :port, 4567
PROJECT_ROOT = File.expand_path(File.dirname(__FILE__))
BOT_DIR = File.join(PROJECT_ROOT, 'bot')

# Utility to read files
helpers do
  def read_file(path)
    File.exist?(path) ? File.read(path) : ""
  end

  def write_file(path, content)
    File.open(path, 'w') { |f| f.write(content) }
  end
end

get '/' do
  erb :home
end

get '/send' do
  erb :send
end

post '/send' do
  output = ''
  Dir.chdir(BOT_DIR) do
    stdout, stderr, status = Open3.capture3('ruby send.rb')
    output = stdout + stderr
  end
  @result = output
  erb :send
end

get '/contacts' do
  @contacts = read_file(File.join(BOT_DIR, 'contacts.txt'))
  erb :contacts
end

post '/contacts' do
  raw_input = params[:raw_contacts]
  emails = raw_input.scan(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/)
  write_file(File.join(BOT_DIR, 'contacts.txt'), emails.join("\n"))
  redirect '/contacts'
end

get '/content' do
  @subject = read_file(File.join(BOT_DIR, 'subject.txt'))
  @body = read_file(File.join(BOT_DIR, 'body.txt'))
  erb :content
end

post '/content' do
  write_file(File.join(BOT_DIR, 'subject.txt'), params[:subject])
  write_file(File.join(BOT_DIR, 'body.txt'), params[:body])
  redirect '/content'
end

get '/smtp' do
  @smtp = read_file(File.join(BOT_DIR, 'smtp-info.txt'))
  erb :smtp
end

post '/smtp' do
  write_file(File.join(BOT_DIR, 'smtp-info.txt'), params[:smtp_info])
  redirect '/smtp'
end

__END__

@@layout
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Email Bot GUI</title>
  <style>
    :root {
      --primary-color: #333;
      --background-color: #f0f0f0;
      --text-color: #333;
      --nav-background-color: #333;
      --nav-text-color: #fff;
      --button-background-color: #4CAF50;
      --button-text-color: #fff;
    }
    body {
      font-family: sans-serif;
      padding: 20px;
      max-width: 800px;
      margin: auto;
      background-color: var(--background-color);
      transition: background-color 0.3s ease;
    }
    nav {
      background-color: var(--nav-background-color);
      color: var(--nav-text-color);
      padding: 10px;
      text-align: center;
      transition: background-color 0.3s ease, color 0.3s ease;
    }
    nav a {
      color: var(--nav-text-color);
      text-decoration: none;
      margin-right: 15px;
      transition: color 0.3s ease;
    }
    nav a:hover {
      color: #ccc;
    }
    hr {
      border: none;
      height: 1px;
      background-color: #ccc;
    }
    h2 {
      color: var(--primary-color);
      transition: color 0.3s ease;
    }
    form {
      margin-top: 20px;
    }
    label {
      display: block;
      margin-bottom: 10px;
    }
    input[type="text"], textarea {
      width: 100%;
      padding: 10px;
      margin-bottom: 20px;
      border: 1px solid #ccc;
    }
    textarea{
      height: 40vh;
    }
    button[type="submit"] {
      background-color: var(--button-background-color);
      color: var(--button-text-color);
      padding: 10px 20px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      transition: background-color 0.3s ease, color 0.3s ease;
    }
    button[type="submit"]:hover {
      background-color: #3e8e41;
    }
    pre {
      background-color: #f0f0f0;
      padding: 10px;
      border: 1px solid #ccc;
    }
    .dark-mode {
      --primary-color: #fff;
      --background-color: #333;
      --text-color: #fff;
      --nav-background-color: #444;
      --nav-text-color: #fff;
      --button-background-color: #4CAF50;
      --button-text-color: #fff;
    }
    .dark-mode p {
  color: #fff;
}

    .dark-mode label{
      color: #fff;
    }
    
    a{
      color: green;
    }

    #theme-toggle {
      position: fixed;
      bottom: 20px;
      left: 20px;
      z-index: 1000;
      background-color: var(--nav-background-color);
      color: var(--nav-text-color);
      padding: 10px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <nav>
    <a href="/">Home</a>
    <a href="/contacts">Contacts</a>
    <a href="/content">Subject/Body</a>
    <a href="/smtp">SMTP Info</a>
    <a href="/send">Send Emails</a>
  </nav>
  <hr>
  <%= yield %>
  <button id="theme-toggle" aria-label="Toggle theme">
    <span class="theme-icon">&#9728;</span>
  </button>
  <script>
const themeToggle = document.getElementById('theme-toggle');
const body = document.body;
let isDarkMode = localStorage.getItem('darkMode') === 'true';

body.classList.toggle('dark-mode', isDarkMode);
if (isDarkMode) {
  themeToggle.innerHTML = '<span class="theme-icon">&#9788;</span>';
} else {
  themeToggle.innerHTML = '<span class="theme-icon">&#9728;</span>';
}

themeToggle.addEventListener('click', () => {
  isDarkMode = !isDarkMode;
  body.classList.toggle('dark-mode', isDarkMode);
  localStorage.setItem('darkMode', isDarkMode);
  if (isDarkMode) {
    themeToggle.innerHTML = '<span class="theme-icon">&#9788;</span>';
  } else {
    themeToggle.innerHTML = '<span class="theme-icon">&#9728;</span>';
  }
});

  </script>
  <style



@@home
<h2>Welcome to the Email Bot GUI</h2>
<p>Thank you for purchasing the upgrade to the Email bot. You can now access all the previous features but now with buttons!</p>
<p>This interface allows you to manage contacts, email content, SMTP settings, and send emails using your existing email bot.</p>
<p>Please reach out to Davids technical solutions if you need any help. Contact information can be found at <a href="https://davidscoding.tech/">davidscoding.tech</a></p>
@@contacts
<h2>Contacts</h2>
<form method="POST">
  <label>Paste your raw contact data below, it will filter out junk.:</label><br>
  <textarea name="raw_contacts"><%= @contacts %></textarea><br><br>
  <button type="submit">Save Contacts</button>
</form>

@@content
<h2>Email Subject & Body</h2>
<form method="POST">
  <label>Subject:</label><br>
  <input type="text" name="subject" value="<%= @subject %>" style="width:100%"><br><br>
  <label>Body:</label><br>
  <textarea name="body"><%= @body %></textarea><br><br>
  <button type="submit">Save</button>
</form>

@@smtp
<h2>SMTP Configuration</h2>
<form method="POST">
  <label>Edit your SMTP info (key: value):</label><br>
  <textarea name="smtp_info"><%= @smtp %></textarea><br><br>
  <button type="submit">Save</button>
</form>

@@send
<h2>Send Emails</h2>
<form method="POST">
  <button type="submit">Send Emails</button>
</form>

<% if @result %>
  <h3>Output:</h3>
  <pre><%= @result %></pre>
<% end %>
