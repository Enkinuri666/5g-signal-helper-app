import 'package:uuid/uuid.dart';

abstract final class PromptSeeds {
  static const _uuid = Uuid();

  static List<Map<String, dynamic>> get all {
    final now = DateTime.now().toIso8601String();
    return _prompts.map((p) {
      return {
        'id': _uuid.v4(),
        'title': p['title'],
        'description': p['description'] ?? '',
        'body': p['body'],
        'category': p['category'] ?? 'General AI',
        'subcategory': p['subcategory'] ?? '',
        'tags': p['tags'] ?? '',
        'ai_models': p['ai_models'] ?? '',
        'difficulty': p['difficulty'] ?? 'Intermediate',
        'variables': p['variables'] ?? '',
        'expected_output': p['expected_output'] ?? '',
        'example': p['example'] ?? '',
        'notes': p['notes'] ?? '',
        'rating': p['rating'] ?? 0,
        'is_favorite': p['is_favorite'] ?? 0,
        'is_pinned': p['is_pinned'] ?? 0,
        'source': p['source'] ?? '',
        'personal_notes': '',
        'collection_id': '',
        'copy_count': 0,
        'use_count': 0,
        'created_at': now,
        'modified_at': now,
        'last_used_at': null,
      };
    }).toList();
  }

  static const List<Map<String, dynamic>> _prompts = [
    // =====================================================
    // ARTIFICIAL INTELLIGENCE - Prompt Engineering
    // =====================================================
    {
      'title': 'System Prompt Framework',
      'description': 'Structured system prompt template for consistent AI behavior',
      'body': '''You are {{role}}, an expert in {{domain}}.

## Core Behavior
- Always provide accurate, well-researched responses
- Cite sources when possible
- Acknowledge uncertainty explicitly
- Use structured formatting for complex answers

## Output Format
- Use markdown for readability
- Include code blocks with language tags
- Break complex topics into numbered steps
- Provide actionable takeaways

## Constraints
- Stay within your domain expertise
- Do not hallucinate facts or statistics
- Ask clarifying questions when the request is ambiguous
- Refuse harmful or unethical requests politely''',
      'category': 'Artificial Intelligence',
      'subcategory': 'Prompt Engineering',
      'tags': 'system prompt, framework, template, foundation',
      'ai_models': 'ChatGPT, Claude, Gemini',
      'difficulty': 'Advanced',
      'variables': 'role::The AI persona role || domain::Area of expertise',
      'rating': 5,
      'is_favorite': 1,
      'is_pinned': 1,
    },
    {
      'title': 'Chain of Thought Reasoning',
      'description': 'Force step-by-step reasoning for complex problems',
      'body': '''Solve the following problem step by step. For each step:

1. State what you're trying to determine
2. Show your reasoning process
3. Verify your intermediate result before proceeding
4. If you're uncertain, state your confidence level

Problem: {{problem}}

Think through this carefully. Show ALL your work. If you catch an error in your reasoning, correct it immediately and explain why your initial approach was wrong.

After reaching your conclusion, provide:
- Final answer clearly stated
- Confidence level (Low/Medium/High)
- Key assumptions made
- Potential edge cases or limitations''',
      'category': 'Artificial Intelligence',
      'subcategory': 'Prompt Engineering',
      'tags': 'chain of thought, reasoning, step-by-step, problem solving',
      'ai_models': 'ChatGPT, Claude, Gemini',
      'difficulty': 'Intermediate',
      'variables': 'problem::The problem to solve step by step',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Few-Shot Learning Template',
      'description': 'Teach an AI through examples before the actual task',
      'body': '''I want you to {{task_description}}. Here are some examples of the expected input and output:

**Example 1:**
Input: {{example_input_1}}
Output: {{example_output_1}}

**Example 2:**
Input: {{example_input_2}}
Output: {{example_output_2}}

**Example 3:**
Input: {{example_input_3}}
Output: {{example_output_3}}

Now, using the same pattern and style demonstrated above, process the following:

Input: {{actual_input}}
Output:''',
      'category': 'Artificial Intelligence',
      'subcategory': 'Prompt Engineering',
      'tags': 'few-shot, examples, learning, pattern',
      'ai_models': 'ChatGPT, Claude, Gemini',
      'difficulty': 'Intermediate',
    },
    {
      'title': 'Prompt Optimizer',
      'description': 'Rewrite a rough prompt into a structured, effective one',
      'body': '''You are a prompt engineering expert. I will give you a rough, unstructured prompt. Your job is to rewrite it into a clear, effective, well-structured prompt optimized for {{target_model}}.

Apply these optimization techniques:
1. Add clear role definition
2. Specify output format explicitly
3. Add constraints and guardrails
4. Include relevant context
5. Add examples if helpful
6. Use delimiters for multi-part inputs
7. Specify the desired tone and style
8. Add error handling instructions

Original rough prompt:
"""
{{rough_prompt}}
"""

Provide:
1. The optimized prompt (ready to copy-paste)
2. A brief explanation of what you changed and why
3. Estimated improvement in output quality (Low/Medium/High)''',
      'category': 'Artificial Intelligence',
      'subcategory': 'Prompt Engineering',
      'tags': 'optimizer, rewrite, improve, structured',
      'ai_models': 'ChatGPT, Claude, Gemini',
      'difficulty': 'Advanced',
      'rating': 4,
      'is_favorite': 1,
    },

    // =====================================================
    // ARTIFICIAL INTELLIGENCE - Agent Design
    // =====================================================
    {
      'title': 'AI Agent System Design',
      'description': 'Design a multi-tool AI agent with defined capabilities',
      'body': '''Design an AI agent with the following specifications:

**Agent Name:** {{agent_name}}
**Purpose:** {{purpose}}

## Agent Architecture

### Available Tools
Define each tool the agent can use:
1. Tool name, description, input parameters, output format
2. When to use each tool
3. Error handling for each tool

### Decision Framework
The agent should follow this decision process:
1. Analyze the user's request
2. Break it into subtasks
3. For each subtask, select the appropriate tool
4. Execute tools in optimal order
5. Synthesize results
6. Verify output quality

### Memory
- Short-term: Current conversation context
- Long-term: User preferences and past interactions
- Working memory: Intermediate results from tool calls

### Guardrails
- Maximum iterations per request: 10
- Timeout per tool call: 30 seconds
- Fallback behavior when tools fail
- Human-in-the-loop escalation criteria''',
      'category': 'Artificial Intelligence',
      'subcategory': 'Agent Design',
      'tags': 'agent, multi-tool, architecture, system design',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Expert',
    },

    // =====================================================
    // ARTIFICIAL INTELLIGENCE - RAG
    // =====================================================
    {
      'title': 'RAG System Prompt Template',
      'description': 'Template for Retrieval Augmented Generation systems',
      'body': '''You are a knowledgeable assistant that answers questions based ONLY on the provided context. Follow these rules strictly:

1. ONLY use information from the provided context to answer
2. If the context doesn't contain enough information, say "I don't have enough information in the provided documents to answer this."
3. NEVER make up or infer information beyond what's explicitly stated
4. Cite the relevant source/chunk for each claim you make
5. If multiple sources conflict, acknowledge the discrepancy

## Context:
"""
{{retrieved_context}}
"""

## User Question:
{{question}}

## Response Format:
- Answer the question directly
- Include inline citations [Source: chunk_id]
- Rate your confidence: High/Medium/Low
- Suggest follow-up questions if relevant''',
      'category': 'Artificial Intelligence',
      'subcategory': 'RAG',
      'tags': 'RAG, retrieval, context, grounding, citations',
      'ai_models': 'Claude, ChatGPT, Gemini',
      'difficulty': 'Advanced',
      'rating': 4,
    },

    // =====================================================
    // PROGRAMMING - Python
    // =====================================================
    {
      'title': 'Python Code Review',
      'description': 'Comprehensive code review prompt for Python',
      'body': '''Review this Python code for quality, correctness, and best practices.

```python
{{code}}
```

Analyze and report on:

1. **Correctness**: Logic errors, edge cases, off-by-one errors
2. **Performance**: Time/space complexity, unnecessary operations, N+1 queries
3. **Security**: Injection vulnerabilities, insecure defaults, secret handling
4. **Style**: PEP 8 compliance, naming conventions, type hints
5. **Architecture**: SOLID principles, separation of concerns, testability
6. **Error Handling**: Exception types, recovery strategies, logging
7. **Testing**: Testability, missing test cases, mocking needs

For each issue found:
- Severity: Critical / Major / Minor / Suggestion
- Line number(s)
- Description of the problem
- Suggested fix with code example''',
      'category': 'Programming',
      'subcategory': 'Python',
      'tags': 'python, code review, quality, best practices',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Python Script Generator',
      'description': 'Generate production-quality Python scripts',
      'body': '''Write a Python script that {{task}}.

Requirements:
- Python 3.11+ syntax
- Type hints on all functions
- Proper error handling with specific exceptions
- Logging using the standard library
- argparse for CLI arguments if applicable
- Follow PEP 8 style
- Include a main() function with if __name__ == "__main__" guard
- Add docstrings to all public functions
- Handle edge cases gracefully

Additional constraints:
- Dependencies: {{dependencies}}
- Input format: {{input_format}}
- Output format: {{output_format}}

Provide the complete, runnable script.''',
      'category': 'Programming',
      'subcategory': 'Python',
      'tags': 'python, script, generator, automation',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
    },

    // =====================================================
    // PROGRAMMING - TypeScript / React
    // =====================================================
    {
      'title': 'React Component Generator',
      'description': 'Generate TypeScript React components with best practices',
      'body': '''Create a React component with the following specifications:

**Component Name:** {{component_name}}
**Purpose:** {{purpose}}
**Props:** {{props_description}}

Requirements:
- TypeScript with strict mode
- Functional component with hooks
- Properly typed props interface
- Memoize expensive computations
- Handle loading, error, and empty states
- Accessible (ARIA labels, keyboard navigation)
- Responsive design
- Follow React best practices (no prop drilling, proper key usage)

Include:
1. Component file with full implementation
2. Props interface/type definition
3. Basic unit test using React Testing Library
4. Usage example

Use modern React patterns:
- Custom hooks for logic extraction
- Suspense-compatible where appropriate
- Server Component compatible if possible''',
      'category': 'Programming',
      'subcategory': 'React',
      'tags': 'react, typescript, component, frontend',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'rating': 4,
    },

    // =====================================================
    // PROGRAMMING - SQL
    // =====================================================
    {
      'title': 'SQL Query Optimizer',
      'description': 'Analyze and optimize SQL queries for performance',
      'body': '''Analyze this SQL query and optimize it for performance:

```sql
{{query}}
```

**Database:** {{database_type}}
**Table size:** {{estimated_rows}} rows
**Current execution time:** {{current_time}}

Provide:
1. **Analysis**: Identify performance bottlenecks
2. **Explain Plan**: Expected execution plan analysis
3. **Optimized Query**: Rewritten for better performance
4. **Index Recommendations**: Which indexes to create
5. **Alternative Approaches**: CTE, window functions, subquery refactoring
6. **Estimated Improvement**: Expected speedup

Consider:
- Full table scans vs index usage
- JOIN order optimization
- WHERE clause sargability
- Unnecessary columns in SELECT
- Subquery vs JOIN performance
- Pagination strategies for large result sets''',
      'category': 'Programming',
      'subcategory': 'SQL',
      'tags': 'sql, optimization, performance, database, query',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'rating': 4,
    },

    // =====================================================
    // PROGRAMMING - Docker
    // =====================================================
    {
      'title': 'Dockerfile Best Practices Generator',
      'description': 'Generate production-optimized Dockerfiles',
      'body': '''Create a production-optimized Dockerfile for the following application:

**Language/Framework:** {{framework}}
**Application type:** {{app_type}}
**Base image preference:** {{base_image}}

Requirements:
- Multi-stage build to minimize image size
- Non-root user for security
- Proper layer caching (dependencies before code)
- Health check endpoint
- Signal handling for graceful shutdown
- Environment variable configuration
- .dockerignore file
- docker-compose.yml for local development

Security requirements:
- No secrets in the image
- Minimal base image
- Pinned dependency versions
- Read-only filesystem where possible
- Drop all capabilities except required ones

Also provide:
- Build command
- Run command
- Estimated final image size
- CI/CD integration notes''',
      'category': 'Programming',
      'subcategory': 'Docker',
      'tags': 'docker, containerization, devops, security, optimization',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // PROGRAMMING - Git
    // =====================================================
    {
      'title': 'Git Workflow Troubleshooter',
      'description': 'Debug and fix common Git issues',
      'body': '''I'm having the following Git issue:

**Problem:** {{problem_description}}
**Current branch:** {{current_branch}}
**What I was trying to do:** {{intended_action}}

Please help me:
1. Diagnose exactly what happened
2. Show the safest way to fix it
3. Explain each Git command you suggest
4. Show how to verify the fix worked
5. Suggest how to prevent this in the future

Important: Before any destructive command, show me what the current state looks like and confirm it's safe to proceed. Prefer non-destructive solutions (reflog, new branch, cherry-pick) over force operations.''',
      'category': 'Programming',
      'subcategory': 'Git',
      'tags': 'git, troubleshooting, version control, recovery',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'rating': 4,
    },

    // =====================================================
    // IMAGE GENERATION
    // =====================================================
    {
      'title': 'Photorealistic Portrait Prompt',
      'description': 'Generate highly detailed photorealistic portrait prompts',
      'body': '''Create a photorealistic portrait with these specifications:

Subject: {{subject_description}}
Setting: {{setting}}
Mood: {{mood}}

Technical parameters:
- Shot type: close-up portrait, 85mm lens, f/1.4
- Lighting: {{lighting_type}}, golden hour/studio Rembrandt
- Camera: Canon EOS R5, 8K resolution
- Post-processing: Subtle color grading, skin retouching

Style modifiers:
- Hyperrealistic, detailed skin texture, visible pores
- Sharp focus on eyes, bokeh background
- Natural skin tones, subsurface scattering
- Professional fashion photography quality
- Editorial magazine quality

Negative prompt: cartoon, illustration, painting, drawing, blurry, low quality, deformed, distorted, ugly, bad anatomy, extra limbs''',
      'category': 'Image Generation',
      'subcategory': 'Photorealism',
      'tags': 'portrait, photorealism, photography, 8K, detailed',
      'ai_models': 'Midjourney, DALL-E, Stable Diffusion',
      'difficulty': 'Advanced',
      'rating': 4,
    },
    {
      'title': 'Cinematic Scene Generator',
      'description': 'Create film-quality cinematic scene descriptions',
      'body': '''Generate a cinematic scene with these parameters:

Scene: {{scene_description}}
Genre: {{genre}}
Color palette: {{color_palette}}

Technical specifications:
- Aspect ratio: 2.39:1 (anamorphic widescreen)
- Camera: ARRI Alexa, anamorphic lens flares
- Lighting: volumetric god rays, atmospheric haze
- Color grading: {{color_grade}} (teal and orange / desaturated / neon)

Cinematic qualities:
- Depth of field with foreground elements
- Dynamic composition using rule of thirds
- Atmospheric particles (dust, rain, smoke)
- Dramatic shadows and highlights
- Film grain texture

Style references: {{style_reference}}

Render in: hyperrealistic, 8K, cinematic, dramatic lighting, volumetric fog, lens flare, film grain''',
      'category': 'Image Generation',
      'subcategory': 'Cinematic',
      'tags': 'cinematic, film, scene, lighting, atmosphere',
      'ai_models': 'Midjourney, Stable Diffusion',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // CYBERSECURITY
    // =====================================================
    {
      'title': 'Web Application Security Audit Checklist',
      'description': 'Comprehensive web app security assessment prompt',
      'body': '''Perform a security audit of the following web application component:

**Technology:** {{tech_stack}}
**Component:** {{component_description}}
**Code/Config:**
```
{{code_or_config}}
```

Check for these vulnerability categories:

**OWASP Top 10:**
1. Injection (SQL, NoSQL, OS command, LDAP)
2. Broken Authentication
3. Sensitive Data Exposure
4. XML External Entities (XXE)
5. Broken Access Control
6. Security Misconfiguration
7. Cross-Site Scripting (XSS)
8. Insecure Deserialization
9. Using Components with Known Vulnerabilities
10. Insufficient Logging & Monitoring

**Additional checks:**
- CSRF protection
- Rate limiting
- Input validation and sanitization
- Error handling (information leakage)
- Secure headers (CSP, HSTS, X-Frame-Options)
- Session management
- API security (authentication, authorization)

For each finding:
- Severity: Critical / High / Medium / Low / Info
- CVSS score estimate
- Description and impact
- Remediation steps with code examples
- References (CWE, CVE if applicable)''',
      'category': 'Cybersecurity',
      'subcategory': 'Web Security',
      'tags': 'security audit, OWASP, web security, vulnerability',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Expert',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'CTF Challenge Solver Framework',
      'description': 'Systematic approach to solving CTF challenges',
      'body': '''Help me solve this CTF challenge:

**Category:** {{category}} (Web / Crypto / Pwn / Reverse / Forensics / Misc)
**Difficulty:** {{difficulty}}
**Challenge description:** {{description}}
**Provided files/data:** {{provided_data}}

Approach:
1. **Reconnaissance**: Identify what we're working with
2. **Analysis**: Examine the challenge components
3. **Hypothesis**: What vulnerability or technique is being tested?
4. **Exploitation**: Step-by-step solution approach
5. **Flag extraction**: How to get the flag

For each step:
- Explain the reasoning
- Show the commands/scripts used
- Note alternative approaches
- Highlight learning points

Tools to consider: {{relevant_tools}}

Important: Only use techniques within the scope of the CTF challenge. This is for educational purposes in a controlled environment.''',
      'category': 'Cybersecurity',
      'subcategory': 'CTF',
      'tags': 'CTF, capture the flag, security, hacking, challenge',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // WINDOWS
    // =====================================================
    {
      'title': 'Windows 11 Performance Optimization',
      'description': 'Comprehensive Windows 11 optimization commands and registry tweaks',
      'body': '''Provide a comprehensive Windows 11 performance optimization guide for {{use_case}}.

Cover these areas:

1. **Startup Optimization**
   - Disable unnecessary startup programs
   - Optimize boot configuration
   - Service optimization

2. **System Performance**
   - Power plan configuration
   - Visual effects optimization
   - Memory management
   - Virtual memory settings

3. **Storage Optimization**
   - Disk cleanup automation
   - TRIM optimization for SSDs
   - Storage Sense configuration
   - Temporary file management

4. **Network Optimization**
   - DNS optimization
   - TCP/IP tuning
   - Network adapter settings

5. **Gaming Optimization** (if applicable)
   - Game Mode settings
   - GPU scheduling
   - DirectStorage
   - Frame rate optimization

Provide:
- PowerShell commands for each optimization
- Registry tweaks where applicable (with backup instructions)
- Group Policy settings
- Before/after comparison expectations
- Rollback instructions for each change

WARNING: Include safety notes for each registry modification.''',
      'category': 'Windows',
      'subcategory': 'Performance Optimization',
      'tags': 'windows 11, optimization, performance, registry, powershell',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'rating': 4,
    },
    {
      'title': 'PowerShell Automation Script',
      'description': 'Generate PowerShell scripts for system automation',
      'body': '''Write a PowerShell script to {{task}}.

Requirements:
- PowerShell 7+ compatible
- Proper error handling with try/catch
- Verbose logging with timestamps
- Parameter validation
- Support -WhatIf for destructive operations
- Comment-based help block
- Progress reporting for long operations

Script structure:
```powershell
#Requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    {{parameters}}
)

# Implementation here
```

Include:
1. Complete script with all functions
2. Usage examples
3. Common troubleshooting scenarios
4. Scheduled task setup if recurring''',
      'category': 'Windows',
      'subcategory': 'PowerShell',
      'tags': 'powershell, automation, scripting, windows',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
    },

    // =====================================================
    // LINUX
    // =====================================================
    {
      'title': 'Bash Script Template',
      'description': 'Production-quality bash script with best practices',
      'body': '''Write a bash script that {{task}}.

Follow these best practices:
- Use #!/usr/bin/env bash
- set -euo pipefail
- Proper argument parsing with getopts or manual parsing
- Color-coded output (info, warn, error)
- Logging to file with timestamps
- Trap for cleanup on EXIT, INT, TERM
- Input validation
- Help/usage function
- Check for required dependencies
- Idempotent where possible

Template:
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=\$'\\n\\t'

readonly SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="\$(basename "\${BASH_SOURCE[0]}")"

# Colors
readonly RED='\\033[0;31m'
readonly GREEN='\\033[0;32m'
readonly YELLOW='\\033[0;33m'
readonly NC='\\033[0m'

log_info()  { echo -e "\${GREEN}[INFO]\${NC} \$*"; }
log_warn()  { echo -e "\${YELLOW}[WARN]\${NC} \$*" >&2; }
log_error() { echo -e "\${RED}[ERROR]\${NC} \$*" >&2; }

cleanup() { # cleanup logic
  true
}
trap cleanup EXIT

main() {
  # Implementation
  true
}

main "\$@"
```''',
      'category': 'Linux',
      'subcategory': 'Bash',
      'tags': 'bash, scripting, linux, automation, template',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'rating': 4,
      'is_favorite': 1,
    },

    // =====================================================
    // WEB AUTOMATION
    // =====================================================
    {
      'title': 'Playwright E2E Test Generator',
      'description': 'Generate end-to-end tests with Playwright',
      'body': '''Generate a Playwright end-to-end test for the following user flow:

**Application URL:** {{url}}
**Flow description:** {{flow_description}}
**Authentication:** {{auth_method}}

Requirements:
- TypeScript with @playwright/test
- Page Object Model pattern
- Proper selectors (data-testid preferred, then role, then text)
- Network request interception for API mocking
- Screenshot on failure
- Retry logic for flaky elements
- Mobile viewport testing
- Accessibility checks

Test structure:
```typescript
import { test, expect } from '@playwright/test';

test.describe('{{test_suite_name}}', () => {
  test.beforeEach(async ({ page }) => {
    // Setup
  });

  test('{{test_case}}', async ({ page }) => {
    // Arrange
    // Act
    // Assert
  });
});
```

Include:
1. Page Object Model class
2. Test file with multiple scenarios
3. Fixture setup
4. playwright.config.ts adjustments if needed''',
      'category': 'Web Automation',
      'subcategory': 'Playwright',
      'tags': 'playwright, testing, e2e, automation, typescript',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'rating': 4,
    },

    // =====================================================
    // SELF-HOSTING
    // =====================================================
    {
      'title': 'Docker Compose Stack Generator',
      'description': 'Generate docker-compose.yml for self-hosted services',
      'body': '''Create a docker-compose.yml configuration for self-hosting {{service}}.

Requirements:
- Docker Compose v3.8+ syntax
- Named volumes for persistent data
- Custom bridge network
- Environment variables via .env file
- Health checks for all services
- Restart policies
- Resource limits
- Reverse proxy integration (Traefik/Nginx Proxy Manager)
- SSL/TLS via Let's Encrypt
- Backup volume mapping

Include:
1. docker-compose.yml
2. .env.example with all variables
3. Required directory structure
4. First-run setup instructions
5. Backup and restore commands
6. Update procedure
7. Monitoring integration (optional)

Security:
- No default passwords
- Internal network for database
- Read-only filesystem where possible
- Non-root containers''',
      'category': 'Self-Hosting',
      'subcategory': 'Docker',
      'tags': 'docker, compose, self-hosted, homelab, infrastructure',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
    },

    // =====================================================
    // NETWORKING
    // =====================================================
    {
      'title': 'Network Troubleshooting Workflow',
      'description': 'Systematic network issue diagnosis',
      'body': '''Help me troubleshoot this network issue:

**Symptoms:** {{symptoms}}
**Affected devices:** {{devices}}
**Network topology:** {{topology}}
**Recent changes:** {{recent_changes}}

Follow this diagnostic workflow:

1. **Layer 1 - Physical**
   - Cable connectivity, link lights, speed/duplex
   - Commands: ethtool, mii-tool

2. **Layer 2 - Data Link**
   - ARP table, MAC addresses, VLAN tagging
   - Commands: arp -a, bridge fdb, ip link

3. **Layer 3 - Network**
   - IP configuration, routing table, gateway reachability
   - Commands: ip addr, ip route, ping, traceroute

4. **Layer 4 - Transport**
   - Port connectivity, firewall rules, NAT
   - Commands: ss -tlnp, iptables -L, nftables

5. **Layer 7 - Application**
   - DNS resolution, HTTP connectivity, service status
   - Commands: dig, nslookup, curl, systemctl

For each layer, provide:
- Diagnostic commands to run
- What the output means
- How to fix common issues found
- When to escalate to the next layer''',
      'category': 'Networking',
      'subcategory': 'TCP/IP',
      'tags': 'networking, troubleshooting, diagnosis, tcp/ip',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // BUSINESS - Marketing
    // =====================================================
    {
      'title': 'Marketing Copy Generator',
      'description': 'Generate compelling marketing copy for any platform',
      'body': '''Create marketing copy for {{business_name}} in the {{industry}} industry.

**Platform:** {{platform}} (Social Media / Email / Landing Page / Ad)
**Goal:** {{goal}} (Awareness / Leads / Sales / Engagement)
**Target Audience:** {{audience}}
**Tone:** {{tone}} (Professional / Casual / Urgent / Inspirational)
**Key Message:** {{key_message}}
**CTA:** {{call_to_action}}

Generate:
1. **Headline** (5 variations, A/B test ready)
2. **Subheadline** (supporting the headline)
3. **Body Copy** ({{length}} words)
4. **Call to Action** (3 variations)
5. **Social proof element** (testimonial/stat template)
6. **Hashtags** (if social media, 10-15 relevant tags)

Copywriting frameworks to apply:
- AIDA (Attention, Interest, Desire, Action)
- PAS (Problem, Agitation, Solution)
- Before-After-Bridge

Avoid: clickbait, false claims, manipulative urgency''',
      'category': 'Business',
      'subcategory': 'Marketing',
      'tags': 'marketing, copywriting, advertising, social media',
      'ai_models': 'ChatGPT, Claude',
      'difficulty': 'Intermediate',
    },

    // =====================================================
    // CREATIVE - Writing
    // =====================================================
    {
      'title': 'Content Writing Assistant',
      'description': 'Generate well-structured long-form content',
      'body': '''Write a comprehensive article about {{topic}}.

**Type:** {{content_type}} (Blog Post / Tutorial / Guide / Opinion)
**Length:** {{word_count}} words
**Audience:** {{audience}}
**Tone:** {{tone}}
**SEO Keywords:** {{keywords}}

Structure:
1. Compelling headline with primary keyword
2. Hook opening (question, statistic, or story)
3. Table of contents for articles over 1500 words
4. Logical section progression with H2/H3 headings
5. Data and examples to support claims
6. Actionable takeaways
7. Conclusion with clear next steps
8. Meta description (155 characters)

Writing quality:
- Active voice preferred
- Short paragraphs (2-3 sentences)
- Transition sentences between sections
- Mix of sentence lengths for rhythm
- Avoid jargon unless audience-appropriate
- Include relevant internal/external link suggestions''',
      'category': 'Creative',
      'subcategory': 'Writing',
      'tags': 'writing, content, blog, SEO, article',
      'ai_models': 'ChatGPT, Claude',
      'difficulty': 'Intermediate',
    },

    // =====================================================
    // MEDIA PROCESSING
    // =====================================================
    {
      'title': 'FFmpeg Command Generator',
      'description': 'Generate complex FFmpeg commands for media processing',
      'body': '''Generate an FFmpeg command for the following task:

**Task:** {{task}}
**Input file(s):** {{input}}
**Output format:** {{output_format}}
**Quality target:** {{quality}}

Consider:
1. Codec selection (H.264/H.265/AV1/VP9)
2. Hardware acceleration (NVENC, QSV, VAAPI)
3. Quality settings (CRF, bitrate, two-pass)
4. Audio handling (codec, bitrate, channels)
5. Subtitle handling (burn-in vs soft subs)
6. Filter chain (scale, crop, deinterlace, denoise)
7. Metadata preservation

Provide:
1. The complete FFmpeg command
2. Explanation of each flag
3. Alternative commands for different quality/speed tradeoffs
4. Estimated file size
5. Batch processing script for multiple files''',
      'category': 'Media Processing',
      'subcategory': 'FFmpeg',
      'tags': 'ffmpeg, video, audio, encoding, transcoding',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'rating': 4,
    },

    // =====================================================
    // IPTV & STREAMING
    // =====================================================
    {
      'title': 'M3U Playlist Organizer',
      'description': 'Organize and clean M3U/M3U8 playlist files',
      'body': '''Help me organize this M3U playlist:

**Task:** {{task}} (Clean / Merge / Sort / Deduplicate / Validate)

Requirements:
1. Parse the M3U/M3U8 format correctly
2. Extract metadata: group-title, tvg-name, tvg-logo, tvg-id
3. Remove duplicate entries (by URL or name)
4. Sort by group, then alphabetically by name
5. Validate stream URLs (check format)
6. Generate clean output in standard M3U format

Python script to accomplish this:
- Read one or more M3U files
- Parse EXTINF lines for metadata
- Apply requested transformations
- Output cleaned playlist
- Generate report: total channels, duplicates removed, groups found

Additional features:
- EPG matching by tvg-id
- Logo URL validation
- Group renaming/merging
- Channel name standardization''',
      'category': 'IPTV & Streaming',
      'subcategory': 'M3U Playlist Management',
      'tags': 'IPTV, M3U, playlist, streaming, organization',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
    },

    // =====================================================
    // FINANCE & ANALYTICS
    // =====================================================
    {
      'title': 'Data Analysis Prompt',
      'description': 'Structured data analysis and visualization request',
      'body': '''Analyze the following dataset:

**Data description:** {{data_description}}
**Goal:** {{analysis_goal}}
**Tool:** {{tool}} (Python/Pandas, R, SQL, Excel)

Perform:
1. **Exploratory Data Analysis**
   - Summary statistics
   - Missing value analysis
   - Distribution of key variables
   - Correlation analysis

2. **Data Cleaning**
   - Handle missing values
   - Remove outliers (with justification)
   - Data type corrections
   - Feature engineering if beneficial

3. **Analysis**
   - {{specific_analysis}}
   - Statistical tests where appropriate
   - Confidence intervals

4. **Visualization**
   - Charts appropriate for the data type
   - Clear labels and titles
   - Color-blind friendly palette
   - Publication-quality formatting

5. **Insights**
   - Key findings (3-5 bullet points)
   - Actionable recommendations
   - Limitations and caveats
   - Suggested follow-up analyses''',
      'category': 'Finance & Analytics',
      'subcategory': 'Data Visualization',
      'tags': 'data analysis, visualization, statistics, pandas',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // WEB RESEARCH
    // =====================================================
    {
      'title': 'Web Scraping Template Generator',
      'description': 'Generate ethical web scraping scripts',
      'body': '''Create a web scraping script for collecting publicly available data:

**Target:** {{target_description}} (public data only)
**Data fields:** {{fields}}
**Output format:** {{output_format}} (CSV/JSON/SQLite)

Requirements:
- Respect robots.txt
- Implement rate limiting ({{rate}} requests/second max)
- Proper User-Agent header
- Handle pagination
- Error handling and retries with exponential backoff
- Data validation before saving
- Logging of all operations

Technical choices:
- Library: {{library}} (BeautifulSoup / Scrapy / Playwright)
- Anti-detection: Reasonable delays, rotating user agents
- Storage: Incremental saving (don't lose data on crash)

Ethical guidelines:
- Only scrape publicly accessible pages
- Respect rate limits and ToS
- Don't overload the target server
- Cache responses to avoid redundant requests
- Include attribution where required''',
      'category': 'Web Research',
      'subcategory': 'Web Scraping',
      'tags': 'scraping, data collection, python, automation',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // KNOWLEDGE MANAGEMENT
    // =====================================================
    {
      'title': 'SOP Template Generator',
      'description': 'Create standardized operating procedures',
      'body': '''Create a Standard Operating Procedure (SOP) for:

**Process:** {{process_name}}
**Department:** {{department}}
**Frequency:** {{frequency}}

## SOP Structure

### 1. Purpose
Why this procedure exists and what it achieves.

### 2. Scope
Who this applies to and when.

### 3. Prerequisites
- Required access/permissions
- Required tools/software
- Required knowledge/training

### 4. Procedure
Step-by-step instructions with:
- Numbered steps
- Screenshots/diagrams where helpful
- Decision points (if/then branches)
- Expected outcomes at each step
- Time estimates

### 5. Verification
How to confirm the procedure was completed correctly.

### 6. Troubleshooting
Common issues and their solutions.

### 7. Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {{date}} | {{author}} | Initial version |

Make it clear, actionable, and followable by someone with basic knowledge of {{department}}.''',
      'category': 'Knowledge Management',
      'subcategory': 'SOPs',
      'tags': 'SOP, procedure, documentation, process, template',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
    },

    // =====================================================
    // REVERSE ENGINEERING
    // =====================================================
    {
      'title': 'Binary Analysis Workflow',
      'description': 'Systematic approach to analyzing unknown binaries',
      'body': '''Analyze this binary/code sample for educational purposes:

**File type:** {{file_type}} (PE/ELF/Mach-O/APK)
**Architecture:** {{architecture}} (x86/x64/ARM)
**Context:** {{context}} (CTF/Research/Malware Analysis Lab)

Analysis workflow:

1. **Static Analysis**
   - File headers and metadata
   - String extraction
   - Import/Export table analysis
   - Section analysis
   - Entropy analysis (packing detection)

2. **Dynamic Analysis** (in isolated sandbox)
   - System call tracing
   - Network activity monitoring
   - File system changes
   - Registry modifications (Windows)
   - Process behavior

3. **Disassembly**
   - Identify main() or entry point
   - Control flow analysis
   - Function identification
   - Key algorithm identification

4. **Decompilation**
   - Reconstruct high-level logic
   - Variable and function renaming
   - Pattern recognition

Tools: Ghidra, IDA Pro, radare2, x64dbg, Wireshark, Process Monitor

Note: This analysis is for educational/defensive purposes in a controlled lab environment.''',
      'category': 'Reverse Engineering',
      'subcategory': 'Binary Analysis',
      'tags': 'reverse engineering, binary analysis, disassembly, security research',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Expert',
    },

    // =====================================================
    // PROGRAMMING - Flutter
    // =====================================================
    {
      'title': 'Flutter Widget Generator',
      'description': 'Generate custom Flutter widgets with animations',
      'body': '''Create a Flutter widget with these specifications:

**Widget name:** {{widget_name}}
**Purpose:** {{purpose}}
**Platform:** {{platform}} (Android / iOS / Web / All)

Requirements:
- Null safety
- Const constructors where possible
- Responsive to screen size
- Theme-aware (supports light/dark)
- Proper key usage
- Performance optimized (RepaintBoundary, const, etc.)
- Accessibility (Semantics widget)

Include:
1. Widget class with full implementation
2. State management (if stateful)
3. Animation controller setup (if animated)
4. Usage example in a parent widget
5. Custom painter (if complex visuals)

Material Design 3 compliance:
- Use Material 3 components
- Follow elevation system
- Support dynamic color
- Proper typography scale''',
      'category': 'Programming',
      'subcategory': 'Flutter',
      'tags': 'flutter, dart, widget, mobile, cross-platform',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
    },

    // =====================================================
    // PROGRAMMING - API Design
    // =====================================================
    {
      'title': 'REST API Design Review',
      'description': 'Review and improve REST API design',
      'body': '''Review this REST API design:

**Endpoints:**
```
{{api_endpoints}}
```

Evaluate against:

1. **RESTful conventions**
   - Resource naming (nouns, plural)
   - HTTP method usage
   - Status code selection
   - URL structure and hierarchy

2. **Security**
   - Authentication mechanism
   - Authorization model
   - Rate limiting
   - Input validation
   - CORS configuration

3. **Performance**
   - Pagination strategy
   - Filtering and sorting
   - Field selection (sparse fieldsets)
   - Caching headers
   - Compression

4. **Developer Experience**
   - Consistent error format
   - Versioning strategy
   - Documentation (OpenAPI/Swagger)
   - SDK-friendly design

5. **Scalability**
   - Statelessness
   - Idempotency
   - Batch operations
   - Async operations for long-running tasks

Provide improved endpoint design with examples.''',
      'category': 'Programming',
      'subcategory': 'APIs',
      'tags': 'API, REST, design, architecture, review',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'rating': 4,
    },

    // =====================================================
    // PERSONAL ARCHIVE
    // =====================================================
    {
      'title': 'Learning Plan Generator',
      'description': 'Create structured learning plans for any topic',
      'body': '''Create a structured learning plan for {{topic}}.

**Current level:** {{current_level}} (Beginner / Intermediate / Advanced)
**Time available:** {{hours_per_week}} hours per week
**Target timeline:** {{timeline}}
**Learning style:** {{style}} (Visual / Reading / Hands-on / Video)
**Goal:** {{goal}}

Generate:

1. **Prerequisites Assessment**
   - What you should already know
   - Quick self-test questions
   - Gap analysis

2. **Learning Path** (week by week)
   - Core concepts in order
   - Recommended resources (free + paid)
   - Practice exercises
   - Mini-projects
   - Milestones

3. **Resources**
   - Books (ranked by quality)
   - Online courses
   - YouTube channels
   - Documentation
   - Communities (Discord, Reddit, Forums)
   - Practice platforms

4. **Project Ideas** (progressive difficulty)
   - Beginner project
   - Intermediate project
   - Capstone project

5. **Assessment**
   - How to measure progress
   - Certification options
   - Portfolio building tips''',
      'category': 'Personal Archive',
      'subcategory': 'Projects',
      'tags': 'learning, education, study plan, self-improvement',
      'ai_models': 'ChatGPT, Claude',
      'difficulty': 'Beginner',
      'rating': 3,
    },

    // =====================================================
    // VIDEO GENERATION
    // =====================================================
    {
      'title': 'Video Prompt - Cinematic Short',
      'description': 'Generate prompts for AI video generation tools',
      'body': '''Create a cinematic video prompt:

**Scene:** {{scene_description}}
**Duration:** {{duration}} seconds
**Aspect ratio:** {{aspect_ratio}}
**Style:** {{style}}

Camera specifications:
- Movement: {{camera_movement}} (dolly, pan, tilt, crane, steadicam, drone)
- Speed: {{speed}} (slow motion, normal, time-lapse)
- Lens: {{lens}} (wide, telephoto, macro, anamorphic)
- Focus: {{focus}} (deep, shallow, rack focus, pull focus)

Lighting:
- Type: {{lighting}} (natural, studio, neon, golden hour, blue hour)
- Direction: {{light_direction}}
- Quality: {{light_quality}} (hard, soft, diffused)

Post-production look:
- Color grading: {{color_grade}}
- Film stock emulation: {{film_stock}}
- Special effects: {{effects}}

Negative prompt: jittery, low quality, morphing artifacts, inconsistent lighting, flickering''',
      'category': 'Video Generation',
      'subcategory': 'Cinematic Video',
      'tags': 'video, cinematic, AI generation, camera, lighting',
      'ai_models': 'Runway, Pika, Sora',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // RESEARCH & KNOWLEDGE
    // =====================================================
    {
      'title': 'Research Paper Summarizer',
      'description': 'Extract key information from academic papers',
      'body': '''Summarize this research paper/document:

"""
{{paper_content}}
"""

Provide a structured summary:

1. **One-line Summary** (tweet-length)

2. **Key Findings** (3-5 bullet points)

3. **Methodology**
   - Approach used
   - Data sources
   - Sample size/scope

4. **Main Arguments**
   - Thesis/hypothesis
   - Supporting evidence
   - Counterarguments addressed

5. **Implications**
   - Practical applications
   - Limitations
   - Future research directions

6. **Critical Assessment**
   - Strengths of the paper
   - Weaknesses or gaps
   - How it relates to existing literature

7. **Key Quotes** (3 most important, with page numbers if available)

8. **Citation** (APA format)

Difficulty level of the source material: {{difficulty}}
Target audience for this summary: {{audience}}''',
      'category': 'Research & Knowledge',
      'subcategory': 'Academic Papers',
      'tags': 'research, academic, summary, paper, analysis',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'rating': 4,
    },

    // =====================================================
    // PROGRAMMING - Next.js
    // =====================================================
    {
      'title': 'Next.js App Router Page Generator',
      'description': 'Generate Next.js pages with App Router patterns',
      'body': '''Create a Next.js page/route with these specifications:

**Route:** {{route_path}}
**Type:** {{page_type}} (Static / Dynamic / Server Action / API Route)
**Data source:** {{data_source}}

Requirements:
- App Router (Next.js 14+)
- TypeScript strict mode
- Server Components by default
- Client Components only where needed ('use client')
- Proper metadata export
- Loading and error boundaries
- Streaming with Suspense
- Proper caching strategy

Include:
1. page.tsx - Main page component
2. layout.tsx - If custom layout needed
3. loading.tsx - Loading state
4. error.tsx - Error boundary
5. Server Actions for mutations
6. Zod schema for validation

Performance:
- Minimize client-side JavaScript
- Use Image component for images
- Implement proper ISR/SSG/SSR strategy
- Edge runtime where beneficial''',
      'category': 'Programming',
      'subcategory': 'Next.js',
      'tags': 'nextjs, react, typescript, app router, server components',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
    },

    // =====================================================
    // ADDITIONAL ESSENTIAL PROMPTS
    // =====================================================
    {
      'title': 'Code Explanation Expert',
      'description': 'Explain complex code at any level of detail',
      'body': '''Explain this code in detail:

```{{language}}
{{code}}
```

Explanation level: {{level}} (Beginner / Intermediate / Expert)

Provide:
1. **High-level overview** - What does this code do? (1-2 sentences)
2. **Line-by-line breakdown** - What each significant line/block does
3. **Data flow** - How data moves through the code
4. **Design patterns** - Any patterns used and why
5. **Complexity** - Time and space complexity
6. **Potential issues** - Edge cases, bugs, performance concerns
7. **Improvements** - How could this be written better?

Use analogies where helpful for the target audience level.''',
      'category': 'Programming',
      'subcategory': 'Python',
      'tags': 'code explanation, learning, education, analysis',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'rating': 4,
    },
    {
      'title': 'API Integration Template',
      'description': 'Template for integrating third-party APIs',
      'body': '''Create an API integration for {{api_name}}:

**Base URL:** {{base_url}}
**Authentication:** {{auth_type}} (API Key / OAuth2 / Bearer Token)
**Language:** {{language}}

Requirements:
- Type-safe request/response models
- Automatic retry with exponential backoff
- Rate limiting compliance
- Error handling with typed exceptions
- Request/response logging
- Timeout configuration
- Connection pooling

Implementation:
1. Client class with all endpoints
2. Request/response DTOs
3. Error handling middleware
4. Authentication handler
5. Rate limiter
6. Unit tests with mocked responses
7. Usage examples

Best practices:
- Don't hardcode credentials
- Use environment variables
- Implement circuit breaker pattern
- Cache responses where appropriate
- Handle pagination automatically''',
      'category': 'Programming',
      'subcategory': 'APIs',
      'tags': 'API, integration, client, REST, HTTP',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
    },
    {
      'title': 'Database Schema Designer',
      'description': 'Design normalized database schemas',
      'body': '''Design a database schema for {{application}}:

**Requirements:** {{requirements}}
**Database:** {{database}} (PostgreSQL / MySQL / SQLite / MongoDB)
**Expected scale:** {{scale}}

Provide:
1. **Entity-Relationship Diagram** (text-based)
2. **Table definitions** with:
   - Column names, types, constraints
   - Primary keys, foreign keys
   - Indexes (including composite)
   - Check constraints
3. **Normalization** (at least 3NF)
4. **Migration scripts** (SQL)
5. **Seed data** for testing
6. **Common queries** with expected performance
7. **Scaling considerations**
   - Partitioning strategy
   - Read replica needs
   - Caching layer

Consider:
- Soft deletes vs hard deletes
- Audit trail (created_at, updated_at, created_by)
- Multi-tenancy if needed
- Full-text search requirements
- JSON/JSONB for flexible fields''',
      'category': 'Programming',
      'subcategory': 'SQL',
      'tags': 'database, schema, design, SQL, architecture',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'rating': 4,
    },
    {
      'title': 'Debugging Assistant',
      'description': 'Systematic debugging approach for any error',
      'body': '''Help me debug this issue:

**Error message:**
```
{{error_message}}
```

**Code context:**
```{{language}}
{{code_context}}
```

**What I expected:** {{expected_behavior}}
**What actually happened:** {{actual_behavior}}
**Steps to reproduce:** {{steps}}
**Environment:** {{environment}}

Debugging approach:
1. Parse the error message - what exactly is it telling us?
2. Identify the root cause vs symptoms
3. Check the most likely causes first
4. Provide step-by-step fix
5. Explain WHY the fix works
6. Suggest preventive measures

If you need more context, tell me exactly what additional information would help you diagnose this.''',
      'category': 'Programming',
      'subcategory': 'Python',
      'tags': 'debugging, error, troubleshooting, fix',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'rating': 5,
      'is_favorite': 1,
    },
  ];
}
