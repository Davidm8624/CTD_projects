require 'pony'
require 'csv'

# Read SMTP configuration from smtp-info.txt file
def read_smtp_config(file_path)
  smtp_config = {}
  
  File.readlines(file_path).each do |line|
    line.strip!  # Clean up leading/trailing whitespaces
    next if line.empty?  # Skip empty lines

    # Ensure the line contains an '=' to separate the key and value
    if line.include?('=')
      key, value = line.split('=', 2)  # Split only at the first '='

      # Store the key-value pair, stripping extra spaces
      smtp_config[key.strip.to_sym] = value.strip
    else
      # Warn if a line does not have the expected format
      puts "Skipping invalid line in SMTP config: #{line}"
    end
  end
  
  # Ensure required keys are present
  required_keys = [:address, :port, :user_name, :password, :domain]
  missing_keys = required_keys.select { |key| smtp_config[key].nil? }

  if missing_keys.any?
    puts "Missing required SMTP configuration keys: #{missing_keys.join(', ')}"
    exit(1)
  end

  smtp_config
end

# Read email content from content.txt file
def read_email_content(file_path)
  content = {}
  
  # Read the content.txt file to extract Subject and Body
  File.readlines(file_path).each do |line|
    if line.strip.start_with?("Subject:")
      content[:subject] = line.strip.sub("Subject:", "").strip
    elsif line.strip.start_with?("Body:")
      content[:body] = line.strip.sub("Body:", "").strip
    end
  end
  
  content
end

# Read contacts from file and filter out invalid/missing emails
# Check if the email is valid
def valid_email?(email)
  # Simple regex for validating email format
  email =~ /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
end

# Read contacts from file and filter out invalid/missing emails
def read_contacts(file_path)
  contacts = []

  # Read and parse the file line by line
  File.readlines(file_path).each_with_index do |line, idx|
    email = line.strip # Get the whole line as the email

    # Skip if the email is empty or invalid
    if email.empty? || !valid_email?(email)
      puts "Skipping invalid contact on line #{idx + 1}: #{line.strip}" # Debugging output for invalid contacts
      next
    end

    # Only store the email address in the contacts array
    contacts << email
  end

  # Check if we have any valid contacts
  if contacts.empty?
    puts "**************************"
    puts "No contacts found in #{file_path}. Please check the file."
    puts "**************************"
  end

  contacts
end

def send_email(contact, smtp_config, email_content, sent_emails)
  # Check if this email has been sent already
  if sent_emails.include?(contact)
    puts "Skipping email to #{contact} (already sent)"
    return
  end

  # Send the email
  begin
    Pony.mail(
      to: contact,
      subject: email_content[:subject],
      body: email_content[:body],
      from: smtp_config[:user_name],
      via: :smtp,
      smtp: {
        address: smtp_config[:address],
        port: smtp_config[:port],
        user_name: smtp_config[:user_name],
        password: smtp_config[:password],
        domain: smtp_config[:domain]
      }
    )
    # Mark this email as sent only if it was successfully sent
    sent_emails << contact
    puts "Email sent to #{contact}"
  rescue => e
    puts "Error sending email to #{contact}: #{e.message}"
  end
end


# Send emails to contacts from the file
def send_emails_from_file(file_path, smtp_config, email_content, sent_emails)
  contacts = read_contacts(file_path)

  if contacts.empty?
    puts "No contacts found in #{file_path}. Please check the file."
    return
  end

  # Send an email to each contact
  contacts.each do |contact|
    send_email(contact, smtp_config, email_content, sent_emails)
  end
end

# Main logic: run the script when executed manually
puts "Sending emails..."

# Read SMTP configuration from smtp-info.txt
smtp_config = read_smtp_config('smtp-info.txt')

# Debug: Check SMTP configuration
puts "SMTP Config: #{smtp_config}"

# Read the email content from content.txt
email_content = read_email_content('content.txt')

# Debug: Check email content
puts "Email Content: #{email_content}"

# Check if email content is valid
if email_content[:subject].nil? || email_content[:body].nil?
  puts "Error: Email content is missing Subject or Body."
  exit(1)
end

# Keep track of sent emails to avoid duplicates
sent_emails = []

# Update the file path to your contact file (choose between contacts.txt and test-contact.txt)
send_emails_from_file('test-contact.txt', smtp_config, email_content, sent_emails)
