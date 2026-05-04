
import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Cloud, Shield, Globe, Server, Activity, Layers, 
  Terminal, Database, HardDrive, Cpu, ExternalLink,
  ChevronRight, Info, CheckCircle
} from 'lucide-react';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { atomDark } from 'react-syntax-highlighter/dist/esm/styles/prism';

const tasks = [
  {
    id: 'task1',
    icon: <Globe size={20} />,
    title: 'Task 1: Networking & NAT',
    desc: 'Custom VPC with 4 subnets, Internet Gateway, and NAT Gateway for private subnet egress.',
    content: "Traffic from private instances routes through the NAT Gateway in the public subnet. Used 'depends_on' meta-argument to ensure correct resource ordering between IGW and NAT.",
    code: 'resource "aws_nat_gateway" "nat" {\n  allocation_id = aws_eip.nat.id\n  subnet_id     = aws_subnet.public[0].id\n  depends_on    = [aws_internet_gateway.igw]\n}',
    images: [
      { path: './screenshots/task1_vpc_console_1776629380978.png', caption: 'VPC Architecture' },
      { path: './screenshots/task1_subnets_console_full_1776629459069.png', caption: 'Subnet Map' },
      { path: './screenshots/task1_nat_gateway_console_1776629656745.png', caption: 'NAT Gateway' },
      { path: './screenshots/task1_public_rt_routes_1776629534921.png', caption: 'Public Routing' }
    ]
  },
  {
    id: 'task2',
    icon: <Shield size={20} />,
    title: 'Task 2: Security & Compute',
    desc: 'Deployment of Web and DB servers with strictly decoupled security groups.',
    content: "Security Groups follow the principle of least privilege. The DB server only allows ingress on port 3306 from the Web Server security group.",
    code: 'variable "instance_type" {\n  validation {\n    condition     = contains(["t3.micro", "t3.small"], var.instance_type)\n    error_message = "Only t3 compute family is allowed."\n  }\n}',
    images: [
      { path: './screenshots/task2_web_sg_inbound_rules_final_1776630315454.png', caption: 'Web Security' },
      { path: './screenshots/task2_ssh_bastion.png', caption: 'Bastion Access' },
      { path: './screenshots/task2_ssh_private.png', caption: 'Private SSH' },
      { path: './screenshots/task2_variable_validation.png', caption: 'Validation Fail' }
    ]
  },
  {
    id: 'task3',
    icon: <Database size={20} />,
    title: 'Task 3: Remote State Management',
    desc: 'S3-backed remote state with DynamoDB locking and backend encryption.',
    content: "Configured a secure remote backend using Amazon S3 for state storage. This enables team collaboration.",
    code: 'terraform {\n  backend "s3" {\n    bucket         = "tf-state-assignment-3"\n    key            = "state/terraform.tfstate"\n    region         = "us-east-1"\n    dynamodb_table = "tf-state-locking"\n    encrypt        = true\n  }\n}',
    images: [
      { path: './screenshots/task3_s3_overview_1776632005831.png', caption: 'S3 Storage' },
      { path: './screenshots/task3_s3_encryption_1776632101644.png', caption: 'AES Encryption' },
      { path: './screenshots/task3_dynamodb_1776632186230.png', caption: 'State Locking' }
    ]
  },
  {
    id: 'task4',
    icon: <Activity size={20} />,
    title: 'Task 4: High Availability (ASG)',
    desc: 'Auto Scaling Group with CloudWatch monitoring.',
    content: "Implemented horizontal scaling based on CPU metrics. When CPU exceeds 60%, the ASG automatically launches new instances.",
    code: '# Stress Test Command\nstress-ng --cpu 4 --timeout 300s',
    images: [
      { path: './screenshots/task4_stress_terminal.png', caption: 'Stress Load' },
      { path: '/screenshots/task4_asg_activity_out.png', caption: 'Scale-Out' },
      { path: '/screenshots/task4_asg_activity_in.png', caption: 'Scale-In' }
    ]
  },
  {
    id: 'task5',
    icon: <Layers size={20} />,
    title: 'Task 5: Load Balancing (ALB)',
    desc: 'Intelligent traffic distribution with health check monitoring.',
    content: "Application Load Balancer acts as the single entry point. Security groups ensure instances only process traffic originating from the ALB.",
    code: 'resource "aws_lb_target_group" "web" {\n  health_check {\n    path = "/"\n    interval = 30\n  }\n}',
    images: [
      { path: './screenshots/task5_alb.png', caption: 'ALB Dashboard' },
      { path: './screenshots/task5_tg.png', caption: 'Health Status' }
    ]
  },
  {
    id: 'task6',
    icon: <Cpu size={20} />,
    title: 'Task 6: Modular Packer AMI',
    desc: 'Custom image creation and codebase modularization.',
    content: "Project organized into distinct modules for better maintainability. Custom AMI built with Packer.",
    code: 'build {\n  sources = ["source.amazon-ebs.ubuntu"]\n  provisioner "shell" {\n    inline = ["sudo apt-get install -y nginx"]\n  }\n}',
    images: [
      { path: './screenshots/task6_custom_ami.png', caption: 'Custom AMI' }
    ]
  }
];

function App() {
  const [activeSection, setActiveSection] = useState('hero');

  useEffect(() => {
    const handleScroll = () => {
      const sections = ['hero', ...tasks.map(t => t.id)];
      for (const id of sections) {
        const el = document.getElementById(id);
        if (el && el.getBoundingClientRect().top < 200) {
          setActiveSection(id);
        }
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div className="app">
      <nav className="sidebar">
        <div className="logo">INFRAX | AWS REPORT</div>
        <ul className="nav-links">
          <li className="nav-item">
            <a 
              href="#hero" 
              className={'nav-link ' + (activeSection === 'hero' ? 'active' : '')}
            >
              <Cloud size={20} /> <span className="nav-text">Project Overview</span>
            </a>
          </li>
          {tasks.map(task => (
            <li key={task.id} className="nav-item">
              <a 
                href={'#' + task.id} 
                className={'nav-link ' + (activeSection === task.id ? 'active' : '')}
              >
                {task.icon} <span className="nav-text">{task.title.split(':')[0]}</span>
              </a>
            </li>
          ))}
        </ul>
        <div style={{ marginTop: 'auto' }}>
          <div className="nav-link">
            <CheckCircle size={16} color="#4caf50" />
            <span className="nav-text" style={{ fontSize: '0.8rem' }}>41 Resources Live</span>
          </div>
        </div>
      </nav>

      <main>
        <section id="hero">
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <h1>AWS Cloud <span className="logo">Provisioning</span></h1>
            <p className="description" style={{ fontSize: '1.4rem' }}>
              Advanced Infrastructure as Code using Terraform and Packer.
            </p>
            <div className="hero-stats">
              <div className="stat-item">
                <span className="stat-value">41</span>
                <span className="stat-label">Resources Managed</span>
              </div>
              <div className="stat-item">
                <span className="stat-value">6</span>
                <span className="stat-label">Core Tasks</span>
              </div>
              <div className="stat-item">
                <span className="stat-value">100%</span>
                <span className="stat-label">Automation Rate</span>
              </div>
            </div>
          </motion.div>

          <div className="glass-card" style={{ marginTop: '3rem' }}>
            <h2><Info size={24} /> Project Mission</h2>
            <p>
              Architecting a secure, scalable, and highly available multi-tier environment 
              on Amazon Web Services. This report showcases the technical implementation 
              and verification of the Devops Assignment 3.
            </p>
          </div>
        </section>

        <div className="task-grid">
          {tasks.map((task) => (
            <motion.section 
              key={task.id} 
              id={task.id}
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true, margin: "-100px" }}
            >
              <div className="glass-card">
                <h2>{task.icon} {task.title}</h2>
                <div className="description">{task.desc}</div>
                <p>{task.content}</p>
                
                <div className="code-container">
                  <div className="image-caption" style={{ textAlign: 'left', background: '#1a1a2e' }}>
                    <Terminal size={14} style={{ marginRight: 8, verticalAlign: 'middle' }} />
                    Implementation Snippet
                  </div>
                  <SyntaxHighlighter language="hcl" style={atomDark} customStyle={{ margin: 0, padding: '1.5rem' }}>
                    {task.code}
                  </SyntaxHighlighter>
                </div>

                <div className="image-gallery">
                  {task.images.map((img, i) => (
                    <motion.div 
                      key={i} 
                      className="image-card"
                      whileHover={{ scale: 1.02 }}
                    >
                      <img src={img.path} alt={img.caption} loading="lazy" />
                      <div className="image-caption">{img.caption}</div>
                    </motion.div>
                  ))}
                </div>
              </div>
            </motion.section>
          ))}
        </div>

        <footer>
          <p>© 2026 Developed for Devops Assignment 03. All rights reserved.</p>
        </footer>
      </main>
    </div>
  );
}

export default App;
