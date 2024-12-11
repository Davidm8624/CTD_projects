require 'net/smtp'

# Function to parse email contacts from a file
def parse_contacts(filename)
  contacts = []
  File.foreach(filename) do |line|
    email = line.strip.match(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/)
    if email
      contacts << email[0]
    else
      puts "Skipping invalid contact: #{line.strip}"
    end
  end
  contacts
end

# Function to parse email subject and body from files
def parse_email_content(subject_file, body_file)
  {
    subject: File.read(subject_file).strip,
    body: File.read(body_file).strip
  }
end

# Function to parse SMTP configuration from smtp-info.txt
def parse_smtp_config(filename)
  smtp_config = {}
  File.foreach(filename) do |line|
    key, value = line.strip.split(':', 2)
    smtp_config[key.to_sym] = value.strip if key && value
  end
  smtp_config
end

# Function to send an email
def send_email(smtp_config, to_email, subject, body)
  message = <<~MESSAGE
    From: #{smtp_config[:user_name]}
    To: #{to_email}
    Subject: #{subject}

    #{body}
  MESSAGE

  Net::SMTP.start(
    smtp_config[:address],
    smtp_config[:port].to_i,
    smtp_config[:domain],
    smtp_config[:user_name],
    smtp_config[:password],
    :plain
  ) do |smtp|
    smtp.send_message(message, smtp_config[:user_name], to_email)
  end
end

# Function to send emails from the contacts file
def send_emails_from_file(smtp_config_file, contacts_file, subject_file, body_file)
  smtp_config = parse_smtp_config(smtp_config_file)
  contacts = parse_contacts(contacts_file)
  email_content = parse_email_content(subject_file, body_file)

  contacts.each do |contact|
    begin
      puts "Processing contact: #{contact}"
      puts "Attempting to send email to #{contact}..."
      send_email(smtp_config, contact, email_content[:subject], email_content[:body])
      puts "Email sent successfully to #{contact}"
    rescue StandardError => e
      puts "Error sending email to #{contact}: #{e.message}"
    end
  end
end

# Main script execution
begin
  smtp_config_file = 'smtp-info.txt'  # Update SMTP configuration file
  contacts_file = 'contacts.txt'      # Update contacts file
  subject_file = 'subject.txt'        # Subject file
  body_file = 'body.txt'              # Body file

  puts "Sending emails..."
  send_emails_from_file(smtp_config_file, contacts_file, subject_file, body_file)
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
