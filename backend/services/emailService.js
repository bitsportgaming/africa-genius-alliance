const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);

class EmailService {
  constructor() {
    this.from = 'Africa Genius Alliance <official@africageniusalliance.com>';
  }

  // Welcome email for new users
  async sendWelcomeEmail(to, userName, userRole) {
    try {
      const subject = userRole === 'genius'
        ? 'Welcome to AGA - Your Genius Journey Begins!'
        : 'Welcome to Africa Genius Alliance!';

      const html = userRole === 'genius'
        ? this.getGeniusWelcomeTemplate(userName)
        : this.getSupporterWelcomeTemplate(userName);

      await resend.emails.send({
        from: this.from,
        to,
        subject,
        html,
      });

      console.log(`✅ Welcome email sent to ${to}`);
    } catch (error) {
      console.error('Failed to send welcome email:', error);
      throw error;
    }
  }

  // Email verification
  async sendVerificationEmail(to, userName, verificationLink) {
    try {
      await resend.emails.send({
        from: this.from,
        to,
        subject: 'Verify Your AGA Email Address',
        html: this.getVerificationTemplate(userName, verificationLink),
      });

      console.log(`✅ Verification email sent to ${to}`);
    } catch (error) {
      console.error('Failed to send verification email:', error);
      throw error;
    }
  }

  // Password reset email
  async sendPasswordResetEmail(to, userName, resetLink) {
    try {
      await resend.emails.send({
        from: this.from,
        to,
        subject: 'Reset Your AGA Password',
        html: this.getPasswordResetTemplate(userName, resetLink),
      });

      console.log(`✅ Password reset email sent to ${to}`);
    } catch (error) {
      console.error('Failed to send password reset email:', error);
      throw error;
    }
  }

  // Genius application status update
  async sendGeniusApplicationEmail(to, userName, status, message) {
    try {
      const subject = status === 'approved'
        ? 'Congratulations! Your Genius Application is Approved'
        : 'Update on Your Genius Application';

      await resend.emails.send({
        from: this.from,
        to,
        subject,
        html: this.getGeniusApplicationTemplate(userName, status, message),
      });

      console.log(`✅ Genius application email sent to ${to}`);
    } catch (error) {
      console.error('Failed to send genius application email:', error);
      throw error;
    }
  }

  // New follower notification
  async sendFollowerNotification(to, userName, followerName) {
    try {
      await resend.emails.send({
        from: this.from,
        to,
        subject: `${followerName} started following you on AGA`,
        html: this.getFollowerNotificationTemplate(userName, followerName),
      });

      console.log(`✅ Follower notification sent to ${to}`);
    } catch (error) {
      console.error('Failed to send follower notification:', error);
    }
  }

  // Vote notification for Genius
  async sendVoteNotification(to, userName, voterCount) {
    try {
      await resend.emails.send({
        from: this.from,
        to,
        subject: `You received ${voterCount} new votes on AGA!`,
        html: this.getVoteNotificationTemplate(userName, voterCount),
      });

      console.log(`✅ Vote notification sent to ${to}`);
    } catch (error) {
      console.error('Failed to send vote notification:', error);
    }
  }

  // Weekly digest for supporters
  async sendWeeklyDigest(to, userName, stats) {
    try {
      await resend.emails.send({
        from: this.from,
        to,
        subject: 'Your Weekly AGA Digest',
        html: this.getWeeklyDigestTemplate(userName, stats),
      });

      console.log(`✅ Weekly digest sent to ${to}`);
    } catch (error) {
      console.error('Failed to send weekly digest:', error);
    }
  }

  // Email templates
  getSupporterWelcomeTemplate(userName) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #0a4d3c 0%, #1a6b52 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #ffffff; padding: 40px 30px; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 20px 0; }
          .footer { background: #f9fafb; padding: 20px; text-align: center; font-size: 14px; color: #6b7280; border-radius: 0 0 10px 10px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome to Africa Genius Alliance! 🌍</h1>
          </div>
          <div class="content">
            <p>Hi ${userName},</p>
            <p>Welcome to Africa's premier platform for merit-based leadership! We're thrilled to have you join our community of engaged citizens shaping the future of our continent.</p>

            <h3>Here's what you can do now:</h3>
            <ul>
              <li><strong>Discover Geniuses:</strong> Browse verified leaders across Political, Technical, Oversight, and Civic categories</li>
              <li><strong>Cast Your Votes:</strong> Support leaders whose vision aligns with your values</li>
              <li><strong>Engage:</strong> Watch live streams, comment on posts, and join the conversation</li>
              <li><strong>Track Impact:</strong> See real-world results from the leaders you support</li>
            </ul>

            <center>
              <a href="https://africageniusalliance.com/dashboard" class="button">Explore Geniuses</a>
            </center>

            <p>Every vote you cast helps elevate merit-driven leadership in Africa. Together, we're building a future where competence matters more than politics.</p>

            <p>Have questions? Reply to this email or visit our <a href="https://africageniusalliance.com/how-it-works">How It Works</a> page.</p>

            <p>Welcome aboard!<br>
            The AGA Team</p>
          </div>
          <div class="footer">
            <p>Africa Genius Alliance<br>
            <a href="https://africageniusalliance.com">africageniusalliance.com</a><br>
            official@africageniusalliance.com</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getGeniusWelcomeTemplate(userName) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #0a4d3c 0%, #1a6b52 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #ffffff; padding: 40px 30px; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 20px 0; }
          .footer { background: #f9fafb; padding: 20px; text-align: center; font-size: 14px; color: #6b7280; border-radius: 0 0 10px 10px; }
          .highlight { background: #fef3c7; padding: 15px; border-left: 4px solid #f59e0b; margin: 20px 0; border-radius: 4px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome, Genius! ⚡</h1>
          </div>
          <div class="content">
            <p>Hi ${userName},</p>
            <p>Congratulations on completing your Genius onboarding! You're now part of an elite community of African leaders driving real change through merit and impact.</p>

            <div class="highlight">
              <strong>🎯 Your application is under review</strong><br>
              Our team is reviewing your credentials and proof of work. You'll receive an email within 3-5 business days with the verification status.
            </div>

            <h3>While you wait, here's what you can do:</h3>
            <ul>
              <li><strong>Complete Your Profile:</strong> Add more details about your vision and achievements</li>
              <li><strong>Start Posting:</strong> Share updates and engage with potential supporters</li>
              <li><strong>Go Live:</strong> Host your first Q&A session to introduce yourself</li>
              <li><strong>Build Your Network:</strong> Connect with other Geniuses in your category</li>
            </ul>

            <center>
              <a href="https://africageniusalliance.com/dashboard" class="button">Go to Dashboard</a>
            </center>

            <p>Remember: On AGA, your impact speaks louder than anything else. We can't wait to see the change you'll create!</p>

            <p>Best regards,<br>
            The AGA Team</p>
          </div>
          <div class="footer">
            <p>Africa Genius Alliance<br>
            <a href="https://africageniusalliance.com">africageniusalliance.com</a><br>
            official@africageniusalliance.com</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getVerificationTemplate(userName, verificationLink) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #0a4d3c 0%, #1a6b52 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #ffffff; padding: 40px 30px; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 20px 0; }
          .footer { background: #f9fafb; padding: 20px; text-align: center; font-size: 14px; color: #6b7280; border-radius: 0 0 10px 10px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Verify Your Email Address</h1>
          </div>
          <div class="content">
            <p>Hi ${userName},</p>
            <p>Thanks for signing up with Africa Genius Alliance! Please verify your email address to unlock full access to the platform.</p>

            <center>
              <a href="${verificationLink}" class="button">Verify Email Address</a>
            </center>

            <p>Or copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #6b7280; font-size: 14px;">${verificationLink}</p>

            <p>This link will expire in 24 hours.</p>

            <p>If you didn't create an AGA account, you can safely ignore this email.</p>

            <p>Best regards,<br>
            The AGA Team</p>
          </div>
          <div class="footer">
            <p>Africa Genius Alliance<br>
            <a href="https://africageniusalliance.com">africageniusalliance.com</a></p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getPasswordResetTemplate(userName, resetLink) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #0a4d3c 0%, #1a6b52 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #ffffff; padding: 40px 30px; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 20px 0; }
          .footer { background: #f9fafb; padding: 20px; text-align: center; font-size: 14px; color: #6b7280; border-radius: 0 0 10px 10px; }
          .warning { background: #fef2f2; border-left: 4px solid #ef4444; padding: 15px; margin: 20px 0; border-radius: 4px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Reset Your Password</h1>
          </div>
          <div class="content">
            <p>Hi ${userName},</p>
            <p>We received a request to reset your password for your AGA account. Click the button below to create a new password:</p>

            <center>
              <a href="${resetLink}" class="button">Reset Password</a>
            </center>

            <p>Or copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #6b7280; font-size: 14px;">${resetLink}</p>

            <div class="warning">
              <strong>⚠️ Security Notice:</strong><br>
              This link will expire in 1 hour. If you didn't request a password reset, please ignore this email and your password will remain unchanged.
            </div>

            <p>For security reasons, never share your password or this reset link with anyone.</p>

            <p>Stay secure,<br>
            The AGA Team</p>
          </div>
          <div class="footer">
            <p>Africa Genius Alliance<br>
            <a href="https://africageniusalliance.com">africageniusalliance.com</a></p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getGeniusApplicationTemplate(userName, status, message) {
    const isApproved = status === 'approved';
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: ${isApproved ? 'linear-gradient(135deg, #10b981 0%, #059669 100%)' : 'linear-gradient(135deg, #0a4d3c 0%, #1a6b52 100%)'}; color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #ffffff; padding: 40px 30px; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 20px 0; }
          .footer { background: #f9fafb; padding: 20px; text-align: center; font-size: 14px; color: #6b7280; border-radius: 0 0 10px 10px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>${isApproved ? '🎉 Congratulations!' : 'Application Update'}</h1>
          </div>
          <div class="content">
            <p>Hi ${userName},</p>
            <p>${message}</p>

            ${isApproved ? `
              <center>
                <a href="https://africageniusalliance.com/dashboard" class="button">Go to Your Profile</a>
              </center>
            ` : ''}

            <p>Best regards,<br>
            The AGA Team</p>
          </div>
          <div class="footer">
            <p>Africa Genius Alliance<br>
            <a href="https://africageniusalliance.com">africageniusalliance.com</a></p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getFollowerNotificationTemplate(userName, followerName) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .content { background: #ffffff; padding: 30px; border-radius: 10px; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 10px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 15px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="content">
            <h2>👋 You have a new follower!</h2>
            <p>Hi ${userName},</p>
            <p><strong>${followerName}</strong> started following you on Africa Genius Alliance.</p>

            <center>
              <a href="https://africageniusalliance.com/dashboard" class="button">View Profile</a>
            </center>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getVoteNotificationTemplate(userName, voterCount) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .content { background: #ffffff; padding: 30px; border-radius: 10px; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 10px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 15px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="content">
            <h2>🗳️ You received ${voterCount} new ${voterCount === 1 ? 'vote' : 'votes'}!</h2>
            <p>Hi ${userName},</p>
            <p>Your impact is resonating! ${voterCount} ${voterCount === 1 ? 'person has' : 'people have'} voted for you on AGA.</p>

            <center>
              <a href="https://africageniusalliance.com/dashboard" class="button">View Your Stats</a>
            </center>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getWeeklyDigestTemplate(userName, stats) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #0a4d3c 0%, #1a6b52 100%); color: white; padding: 30px 20px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #ffffff; padding: 30px; }
          .stat-box { background: #f9fafb; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #f59e0b; }
          .button { display: inline-block; background: #f59e0b; color: white; padding: 12px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; margin: 20px 0; }
          .footer { background: #f9fafb; padding: 20px; text-align: center; font-size: 14px; color: #6b7280; border-radius: 0 0 10px 10px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Your Weekly AGA Digest</h1>
          </div>
          <div class="content">
            <p>Hi ${userName},</p>
            <p>Here's what happened this week on Africa Genius Alliance:</p>

            <div class="stat-box">
              <h3>📊 Your Activity</h3>
              <ul>
                <li>Votes cast: ${stats.votesCast || 0}</li>
                <li>Posts engaged with: ${stats.postsEngaged || 0}</li>
                <li>New followers: ${stats.newFollowers || 0}</li>
              </ul>
            </div>

            <div class="stat-box">
              <h3>🔥 Trending This Week</h3>
              <ul>
                <li>${stats.trendingGeniuses || 'No trending data'}</li>
              </ul>
            </div>

            <center>
              <a href="https://africageniusalliance.com/dashboard" class="button">View Dashboard</a>
            </center>

            <p>Keep engaging and making your voice heard!</p>

            <p>Best,<br>
            The AGA Team</p>
          </div>
          <div class="footer">
            <p>Africa Genius Alliance<br>
            <a href="https://africageniusalliance.com">africageniusalliance.com</a><br>
            <a href="https://africageniusalliance.com/settings">Unsubscribe from weekly digest</a></p>
          </div>
        </div>
      </body>
      </html>
    `;
  }
}

module.exports = new EmailService();
