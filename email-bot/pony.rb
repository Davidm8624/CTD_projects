require 'pony'

# Read SMTP credentials from smtp-info.txt
def load_smtp_info(file_path)
  smtp_info = {}
  File.readlines(file_path).each do |line|
    key, value = line.strip.split(': ', 2)
    smtp_info[key.to_sym] = value
  end
  smtp_info
end

# Read contacts from contacts.txt
def load_contacts(file_path)
  File.readlines(file_path).map(&:strip)
end

# Read email content from content.txt
def load_email_content(file_path)
  email_content = {}
  File.readlines(file_path).each do |line|
    if line.start_with?('Subject:')
      email_content[:subject] = line.sub('Subject: ', '').strip
    elsif line.start_with?('Body:')
      email_content[:body] = line.sub('Body: ', '').strip
    end
  end
  email_content
end

# Send emails to contacts
def send_emails
  smtp_info = load_smtp_info('smtp-info.txt')
  contacts = load_contacts('contacts.txt')
  email_content = load_email_content('content.txt')

  contacts.each_with_index do |recipient, index|
    Pony.mail({
      to: recipient,
      from: smtp_info[:user_name],
      subject: "#{email_content[:subject]} (Email ##{index + 1})",
      body: "#{email_content[:body]}\n\nThis is email ##{index + 1} sent by the bot.",
      via: :smtp,
      via_options: {
        address: smtp_info[:address],
        port: smtp_info[:port].to_i,
        enable_starttls_auto: true,
        user_name: smtp_info[:user_name],
        password: smtp_info[:password],
        authentication: :plain,
        domain: smtp_info[:domain]
      }
    })

    puts "Email ##{index + 1} sent to #{recipient}"
  end
end

# Execute email sending
send_emails
