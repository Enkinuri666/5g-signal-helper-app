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

    // =====================================================
    // CYBERSECURITY (defensive / research)
    // =====================================================
    {
      'title': 'Threat Model a System (STRIDE)',
      'description': 'Produce a STRIDE threat model for an architecture',
      'body': '''You are a senior application security engineer. Build a STRIDE threat model for the system below.

System description:
"""
{{system_description}}
"""

For each component and trust boundary, enumerate threats across the STRIDE categories:
- Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege

For each threat provide:
1. Affected component / data flow
2. Attack scenario (concise)
3. Likelihood and impact (Low/Medium/High)
4. Concrete mitigation and the control that enforces it

End with a prioritized remediation backlog (highest risk first).''',
      'category': 'Cybersecurity',
      'subcategory': 'Secure Coding',
      'tags': 'threat modeling, stride, appsec, design review',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'system_description::Architecture, data flows, and trust boundaries',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Detection Engineering: Sigma Rule',
      'description': 'Draft a Sigma detection rule from an attack technique',
      'body': '''Act as a detection engineer. Given the behaviour below, write a Sigma rule that detects it with minimal false positives.

Behaviour / technique: {{technique}}
Log source: {{log_source}}

Deliver:
1. A valid Sigma rule (title, status, logsource, detection, condition, level, tags with the MITRE ATT&CK id)
2. The assumptions about field names and how to adapt them
3. Known false-positive sources and how to tune them out
4. A test plan describing benign and malicious events to validate the rule''',
      'category': 'Cybersecurity',
      'subcategory': 'Detection Engineering',
      'tags': 'sigma, detection, siem, mitre attack, blue team',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'technique::Attacker behaviour to detect || log_source::e.g. Windows Security, Sysmon, cloudtrail',
      'rating': 5,
    },
    {
      'title': 'Incident Response Runbook',
      'description': 'Generate a containment-to-recovery IR runbook',
      'body': '''You are an incident responder. Produce a runbook for handling this incident type: {{incident_type}}.

Structure it against the NIST IR lifecycle:
1. Preparation prerequisites (tooling, access, logging)
2. Detection & analysis: signals, triage questions, severity criteria
3. Containment: short-term and long-term steps
4. Eradication: how to remove the root cause
5. Recovery: safe restoration and monitoring
6. Post-incident: lessons learned and metrics

For each phase list the concrete commands or console actions, the owner role, and the evidence to preserve for forensics.''',
      'category': 'Cybersecurity',
      'subcategory': 'Incident Response',
      'tags': 'incident response, runbook, nist, blue team, forensics',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'incident_type::e.g. ransomware, BEC, credential theft, web shell',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Explain a CVE for Remediation',
      'description': 'Turn a CVE into a plain-English risk and fix brief',
      'body': '''Summarize the following vulnerability for a mixed audience of engineers and managers.

CVE / advisory: {{cve}}
Our exposure: {{context}}

Provide:
1. What the flaw is, in plain language
2. How an attacker would realistically abuse it (conceptual, not a working exploit)
3. Affected versions and how to confirm we are affected
4. Prioritized remediation: patch, config change, or compensating control
5. Detection ideas while unpatched

Keep it defensive and remediation-focused.''',
      'category': 'Cybersecurity',
      'subcategory': 'Vulnerability Management',
      'tags': 'cve, vulnerability, remediation, patching',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'cve::CVE id or advisory text || context::Where/how the component is used',
      'rating': 4,
    },
    {
      'title': 'CTF Challenge Walkthrough Coach',
      'description': 'Guide learning through a CTF challenge without spoiling',
      'body': '''You are a CTF mentor. I am learning and want to solve this challenge myself.

Category: {{category}}
Challenge details: {{details}}

Coach me:
1. Ask what I have tried so far
2. Give the smallest useful hint, not the full solution
3. Point me to the concept or tool I should study
4. Only reveal the next step if I say I am stuck after trying
5. After I solve it, explain the underlying vulnerability class and how to defend against it''',
      'category': 'Cybersecurity',
      'subcategory': 'CTF',
      'tags': 'ctf, learning, mentor, hints',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'category::e.g. web, pwn, crypto, forensics || details::Challenge prompt and files',
    },

    // =====================================================
    // REVERSE ENGINEERING
    // =====================================================
    {
      'title': 'Explain Disassembly',
      'description': 'Annotate an assembly listing in plain language',
      'body': '''You are a reverse engineering tutor. Explain what the following {{arch}} assembly does.

```
{{assembly}}
```

Provide:
1. A high-level summary of the function purpose
2. A line-by-line or block-by-block annotation
3. Reconstructed pseudo-C equivalent
4. Calling convention, arguments, and return value
5. Any notable tricks (anti-debug, obfuscation, stack canaries)''',
      'category': 'Reverse Engineering',
      'subcategory': 'Assembly',
      'tags': 'assembly, disassembly, annotation, pseudocode',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'arch::x86, x64, or ARM || assembly::The disassembly listing',
      'rating': 5,
    },
    {
      'title': 'Ghidra Decompiler Cleanup',
      'description': 'Refactor messy decompiler output into readable C',
      'body': '''Given raw decompiler output, produce clean, idiomatic C and explain the logic.

Decompiler output:
```
{{code}}
```

Tasks:
1. Rename variables and functions to meaningful names based on behaviour
2. Replace magic numbers with named constants where the meaning is clear
3. Recover structs from pointer arithmetic and field offsets
4. Add comments describing intent
5. Note anything ambiguous where you are inferring rather than certain''',
      'category': 'Reverse Engineering',
      'subcategory': 'Decompilers',
      'tags': 'ghidra, decompiler, cleanup, c, refactor',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'code::Raw decompiler pseudo-C',
      'rating': 4,
    },
    {
      'title': 'PE / ELF Header Triage',
      'description': 'Interpret a binary header dump for quick triage',
      'body': '''Act as a malware analyst doing static triage. Interpret this {{format}} header/section dump.

```
{{dump}}
```

Explain:
1. Entry point, sections, and anything unusual (high entropy, odd section names, RWX)
2. Imports/exports and what capabilities they hint at
3. Signs of packing or obfuscation
4. Suggested safe next analysis steps (all in an isolated lab)
Keep it analytical and defensive.''',
      'category': 'Reverse Engineering',
      'subcategory': 'PE Format',
      'tags': 'pe, elf, static analysis, triage, malware',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'format::PE or ELF || dump::Header and section output',
    },
    {
      'title': 'Debugger Strategy Planner',
      'description': 'Plan a dynamic-analysis session for a target',
      'body': '''You are guiding a dynamic analysis session with {{debugger}}.

Goal: {{goal}}
Target: {{target}}

Produce a plan:
1. Breakpoints to set and why (functions, syscalls, memory writes)
2. What to watch (registers, stack, heap, arguments)
3. How to bypass common anti-debugging checks safely in a lab
4. What artifacts to capture for later
5. Stop conditions that mean the goal is achieved''',
      'category': 'Reverse Engineering',
      'subcategory': 'Dynamic Analysis',
      'tags': 'debugging, dynamic analysis, breakpoints, lab',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'debugger::e.g. x64dbg, gdb, WinDbg || goal::What you want to learn || target::The binary',
    },
    {
      'title': 'Binary Diffing Report',
      'description': 'Compare two binary versions to find the changed logic',
      'body': '''Compare version A and version B of a binary and explain what changed.

Notes about A: {{notes_a}}
Notes about B: {{notes_b}}
Diff observations: {{diff}}

Deliver:
1. Functions added, removed, or modified
2. The most likely purpose of each change (bugfix, feature, patched vuln)
3. If a security patch, the class of the underlying flaw
4. Follow-up questions to confirm your hypothesis''',
      'category': 'Reverse Engineering',
      'subcategory': 'Binary Analysis',
      'tags': 'bindiff, patch diffing, analysis',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'notes_a::Old version notes || notes_b::New version notes || diff::Tool diff output',
    },

    // =====================================================
    // NETWORKING
    // =====================================================
    {
      'title': 'Packet Capture Analysis',
      'description': 'Interpret a pcap summary and find the problem',
      'body': '''You are a network engineer analyzing traffic. Given this capture summary, diagnose the issue.

Summary / Wireshark output:
"""
{{capture}}
"""
Symptom: {{symptom}}

Explain:
1. What the conversation is doing (protocols, handshakes, retransmissions)
2. Where it breaks and the likely cause (MTU, TLS, DNS, RST, latency)
3. The exact filter or follow-up capture to confirm
4. The fix and how to verify it''',
      'category': 'Networking',
      'subcategory': 'TCP/IP',
      'tags': 'wireshark, pcap, tcp, troubleshooting',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'capture::Capture summary || symptom::Observed problem',
      'rating': 4,
    },
    {
      'title': 'Subnet & VLAN Plan',
      'description': 'Design an addressing and VLAN scheme',
      'body': '''Design an IP addressing and VLAN plan for the network below.

Requirements: {{requirements}}
Constraints: {{constraints}}

Provide:
1. VLAN list with purpose and IDs
2. Subnet allocation (CIDR) sized for growth, with usable host counts
3. Gateway and DHCP scope suggestions
4. Inter-VLAN routing and firewall rules at a high level
5. A table summarizing the plan''',
      'category': 'Networking',
      'subcategory': 'VLAN',
      'tags': 'subnetting, vlan, cidr, network design',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'requirements::Sites, segments, device counts || constraints::Existing ranges, hardware',
      'rating': 4,
    },
    {
      'title': 'DNS Troubleshooting Guide',
      'description': 'Systematically diagnose a DNS resolution failure',
      'body': '''Help me diagnose a DNS problem step by step.

Symptom: {{symptom}}
Environment: {{environment}}

Walk through the resolution path:
1. Is it the client resolver, cache, or upstream?
2. The exact dig/nslookup commands to run at each layer and what each result would mean
3. Common causes (split-horizon, TTL, DNSSEC, records missing, wrong search domain)
4. The fix and a verification command''',
      'category': 'Networking',
      'subcategory': 'DNS',
      'tags': 'dns, dig, troubleshooting, resolution',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'symptom::What fails || environment::OS, resolver, network',
    },
    {
      'title': 'WireGuard Tunnel Setup',
      'description': 'Generate a WireGuard config for two peers',
      'body': '''Produce a working WireGuard configuration.

Topology: {{topology}}
Peer A: {{peer_a}}
Peer B: {{peer_b}}

Deliver:
1. wg0.conf for each peer with placeholders for keys
2. The key generation commands
3. AllowedIPs reasoning for full-tunnel vs split-tunnel
4. Firewall/NAT and IP forwarding steps
5. A connectivity test and troubleshooting checklist''',
      'category': 'Networking',
      'subcategory': 'WireGuard',
      'tags': 'wireguard, vpn, tunnel, config',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'topology::site-to-site or road-warrior || peer_a::Endpoint/subnet || peer_b::Endpoint/subnet',
      'rating': 4,
    },
    {
      'title': 'Reverse Proxy Config Reviewer',
      'description': 'Review and harden a reverse proxy configuration',
      'body': '''Review this reverse proxy config for correctness, performance, and security.

Proxy: {{proxy}}
Config:
```
{{config}}
```

Report:
1. Correctness issues (routing, headers, upstream health)
2. Security hardening (TLS, HSTS, header stripping, rate limits)
3. Performance (caching, keepalive, buffering, compression)
4. A corrected config block with comments''',
      'category': 'Networking',
      'subcategory': 'Reverse Proxies',
      'tags': 'nginx, caddy, reverse proxy, tls, hardening',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'proxy::nginx, Caddy, Traefik, HAProxy || config::The config to review',
    },

    // =====================================================
    // SELF-HOSTING
    // =====================================================
    {
      'title': 'Docker Compose Stack Generator',
      'description': 'Produce a hardened docker-compose for a service',
      'body': '''Generate a production-minded docker-compose.yml for: {{service}}.

Requirements: {{requirements}}

Include:
1. Pinned image versions and a healthcheck
2. Named volumes for persistence and a note on backups
3. Environment via .env with secrets called out
4. Resource limits and restart policy
5. A reverse-proxy label/section if applicable
6. Post-deploy verification steps''',
      'category': 'Self-Hosting',
      'subcategory': 'Docker',
      'tags': 'docker, compose, self-hosting, deployment',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'service::App to host || requirements::Ports, storage, integrations',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Home Lab Architecture Review',
      'description': 'Design or critique a home lab topology',
      'body': '''Act as a home lab architect. Given my hardware and goals, propose a clean architecture.

Hardware: {{hardware}}
Goals: {{goals}}

Cover:
1. Hypervisor / OS layout and VM/container split
2. Networking (VLANs, DNS, reverse proxy, remote access)
3. Storage and backup strategy (3-2-1)
4. Monitoring and alerting
5. A phased build order so each step is usable''',
      'category': 'Self-Hosting',
      'subcategory': 'Home Lab',
      'tags': 'home lab, proxmox, architecture, planning',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'hardware::Servers, NAS, network gear || goals::What you want to run',
      'rating': 4,
    },
    {
      'title': '3-2-1 Backup Plan',
      'description': 'Design a resilient backup and restore strategy',
      'body': '''Design a 3-2-1 backup strategy for my self-hosted data.

Data to protect: {{data}}
Constraints: {{constraints}}

Provide:
1. What to back up and at what frequency (RPO)
2. Tooling suggestions (e.g. restic, Borg, snapshots)
3. On-site + off-site targets and encryption
4. A restore test procedure and how often to run it
5. A one-page schedule table''',
      'category': 'Self-Hosting',
      'subcategory': 'Backups',
      'tags': 'backup, restic, borg, 3-2-1, recovery',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'data::Volumes, databases, configs || constraints::Budget, bandwidth, retention',
      'rating': 4,
    },
    {
      'title': 'Kubernetes Manifest Review',
      'description': 'Review a k8s manifest for reliability and security',
      'body': '''Review this Kubernetes manifest and suggest improvements.

```
{{manifest}}
```

Check:
1. Resource requests/limits and probes
2. Security context (non-root, read-only fs, dropped capabilities)
3. Rolling update strategy and replica count
4. Config/secret handling
5. Provide a corrected manifest with comments''',
      'category': 'Self-Hosting',
      'subcategory': 'Kubernetes',
      'tags': 'kubernetes, manifest, review, security',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'manifest::The YAML to review',
    },
    {
      'title': 'Uptime Monitoring Setup',
      'description': 'Plan monitoring and alerting for self-hosted services',
      'body': '''Help me set up monitoring for my self-hosted services.

Services: {{services}}
Preferred stack: {{stack}}

Deliver:
1. What to monitor (uptime, latency, cert expiry, disk, container health)
2. Suggested tools and how they fit together
3. Example alert rules with sensible thresholds
4. Notification routing (avoid alert fatigue)
5. A dashboard layout outline''',
      'category': 'Self-Hosting',
      'subcategory': 'Monitoring',
      'tags': 'monitoring, uptime, alerting, grafana, prometheus',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'services::What to watch || stack::e.g. Uptime Kuma, Prometheus+Grafana',
    },

    // =====================================================
    // WINDOWS
    // =====================================================
    {
      'title': 'PowerShell Script Builder',
      'description': 'Generate a robust PowerShell script for a task',
      'body': '''Write a production-quality PowerShell script that does the following:

Task: {{task}}

Requirements:
1. param() block with validation and comment-based help
2. Error handling with try/catch and -ErrorAction
3. Support -WhatIf / -Confirm for destructive actions
4. Clear progress and verbose output
5. Idempotent where possible
Explain how to run it and any required privileges.''',
      'category': 'Windows',
      'subcategory': 'PowerShell',
      'tags': 'powershell, scripting, automation, windows',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'task::What the script should accomplish',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Windows 11 Debloat Plan',
      'description': 'Safe, reversible optimization of a fresh install',
      'body': '''Recommend a safe optimization plan for Windows 11.

Use case: {{use_case}}
Risk tolerance: {{risk}}

Provide:
1. Which built-in apps/services are safe to remove or disable and why
2. Privacy/telemetry settings worth changing
3. Performance tweaks with the tradeoff for each
4. What NOT to touch (things that break updates or security)
5. How to create a restore point first and revert each change''',
      'category': 'Windows',
      'subcategory': 'Performance Optimization',
      'tags': 'windows 11, debloat, optimization, privacy',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'use_case::gaming, dev, general || risk::conservative or aggressive',
      'rating': 4,
    },
    {
      'title': 'Registry Tweak Explainer',
      'description': 'Explain and safely apply a registry change',
      'body': '''Explain this registry change and how to apply it safely.

Goal: {{goal}}
Key/value (if known): {{key}}

Provide:
1. What the key controls and the effect of changing it
2. The exact path, value name, type, and data
3. A .reg file to apply it and one to revert it
4. Whether a reboot or sign-out is required
5. Risks and how to back up the key first''',
      'category': 'Windows',
      'subcategory': 'Registry',
      'tags': 'registry, regedit, tweak, windows',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'goal::Desired behaviour change || key::Known key if any',
    },
    {
      'title': 'WSL Dev Environment Setup',
      'description': 'Set up a clean WSL2 development environment',
      'body': '''Guide me through setting up a WSL2 dev environment.

Distro: {{distro}}
Stack: {{stack}}

Cover:
1. Enabling WSL2 and installing the distro
2. Base packages, shell, and dotfiles
3. Git, SSH keys, and credential sharing with Windows
4. Editor integration (VS Code remote)
5. Performance tips (file location, memory limits via .wslconfig)''',
      'category': 'Windows',
      'subcategory': 'WSL',
      'tags': 'wsl, wsl2, development, linux, setup',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'distro::e.g. Ubuntu || stack::Languages/tools you need',
      'rating': 4,
    },
    {
      'title': 'Windows Boot / Crash Triage',
      'description': 'Diagnose a boot failure or BSOD methodically',
      'body': '''Help me diagnose a Windows stability problem.

Symptom: {{symptom}}
Recent changes: {{changes}}
Error codes (if any): {{codes}}

Walk me through:
1. Interpreting the stop code or boot error
2. Safe mode / recovery options to try in order
3. Which logs to read (Event Viewer, minidump) and what to look for
4. Most likely causes ranked
5. The fix and how to confirm stability''',
      'category': 'Windows',
      'subcategory': 'Diagnostics',
      'tags': 'bsod, boot, troubleshooting, event viewer',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'symptom::What happens || changes::Recent installs/updates || codes::Stop codes',
    },

    // =====================================================
    // LINUX
    // =====================================================
    {
      'title': 'Bash Script with Safeguards',
      'description': 'Write a robust bash script with strict mode',
      'body': '''Write a bash script for the task below, production quality.

Task: {{task}}

Requirements:
1. Start with set -euo pipefail and an error trap
2. Usage function and argument parsing
3. Dependency checks before running
4. Dry-run flag for destructive operations
5. Clear logging and exit codes
Explain how to run it and required permissions.''',
      'category': 'Linux',
      'subcategory': 'Bash',
      'tags': 'bash, scripting, automation, strict mode',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'task::What the script should do',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'systemd Service Unit',
      'description': 'Create a systemd unit for a long-running process',
      'body': '''Create a systemd service unit for: {{process}}.

Details: {{details}}

Provide:
1. The .service file (Unit, Service, Install) with sensible restart policy
2. Hardening directives (User, NoNewPrivileges, ProtectSystem, etc.)
3. Environment/working directory handling
4. Enable/start/status/journalctl commands
5. How to test failure recovery''',
      'category': 'Linux',
      'subcategory': 'Services',
      'tags': 'systemd, service, unit, hardening',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'process::The program to run || details::Path, user, deps',
      'rating': 4,
    },
    {
      'title': 'Linux Performance Diagnosis',
      'description': 'Find what is slowing a Linux host',
      'body': '''Act as an SRE. Help me find the bottleneck on a Linux host.

Symptom: {{symptom}}

Walk the USE method (Utilization, Saturation, Errors) across CPU, memory, disk, and network:
1. The exact commands to run at each layer (top, vmstat, iostat, ss, etc.)
2. How to read each output
3. Likely causes ranked by the evidence
4. The remediation and how to verify improvement''',
      'category': 'Linux',
      'subcategory': 'System Administration',
      'tags': 'performance, sre, use method, troubleshooting',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'symptom::What is slow or failing',
    },
    {
      'title': 'Permissions & Ownership Fixer',
      'description': 'Diagnose and fix Linux permission problems safely',
      'body': '''Help me resolve a permissions problem without breaking the system.

Symptom: {{symptom}}
Path(s): {{paths}}

Explain:
1. How to read current ownership and mode (ls -l, getfacl)
2. What the correct ownership/mode should be and why
3. The precise chown/chmod/setfacl commands, scoped narrowly
4. Why blanket recursive 777 is dangerous
5. How to verify the fix''',
      'category': 'Linux',
      'subcategory': 'System Administration',
      'tags': 'permissions, chmod, chown, acl',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'symptom::Access error || paths::Affected files/dirs',
    },
    {
      'title': 'Package & Dependency Explainer',
      'description': 'Resolve a package management conflict',
      'body': '''Help me resolve a package problem on {{distro}}.

Error / situation: {{error}}

Provide:
1. What the error means
2. Safe resolution steps for this package manager (apt, dnf, pacman)
3. How to avoid breaking held/critical packages
4. How to roll back if it goes wrong
5. Commands to verify the system is consistent afterward''',
      'category': 'Linux',
      'subcategory': 'Debian',
      'tags': 'apt, dnf, pacman, dependencies, packages',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'distro::Ubuntu/Debian/Fedora/Arch || error::The error text',
    },

    // =====================================================
    // WEB AUTOMATION
    // =====================================================
    {
      'title': 'Playwright Script from a Flow',
      'description': 'Generate a Playwright script for a described flow',
      'body': '''Write a Playwright (TypeScript) script that automates this flow.

Flow: {{flow}}
Target site notes: {{notes}}

Requirements:
1. Robust selectors (roles/text over brittle CSS)
2. Auto-waiting, no fixed sleeps
3. Error handling and a screenshot on failure
4. Config for headless/headed and base URL
5. Comments explaining each step
Respect the site terms of service and robots restrictions.''',
      'category': 'Web Automation',
      'subcategory': 'Playwright',
      'tags': 'playwright, automation, typescript, e2e',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'flow::Steps to automate || notes::Selectors, auth, quirks',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Flaky Test Stabilizer',
      'description': 'Diagnose and fix a flaky browser automation test',
      'body': '''My browser automation test is flaky. Help me stabilize it.

Test description: {{test}}
Symptom / failure: {{failure}}

Analyze:
1. Common flakiness causes (timing, animations, network, test data)
2. How to replace waits with deterministic conditions
3. Isolation and retry strategy
4. A refactored, resilient version of the critical section''',
      'category': 'Web Automation',
      'subcategory': 'Browser Automation',
      'tags': 'flaky tests, stability, waits, automation',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'test::What it does || failure::How it fails',
    },
    {
      'title': 'Selenium to Playwright Migration',
      'description': 'Port a Selenium script to Playwright',
      'body': '''Convert this Selenium script to Playwright and improve it.

```
{{script}}
```

Deliver:
1. The equivalent Playwright script
2. Where auto-waiting removes explicit waits
3. Selector improvements
4. Any behaviour differences to watch for''',
      'category': 'Web Automation',
      'subcategory': 'Selenium',
      'tags': 'selenium, playwright, migration, refactor',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'script::The Selenium code',
    },
    {
      'title': 'API Automation Workflow',
      'description': 'Chain API calls into a reliable automation',
      'body': '''Design an API automation workflow.

Goal: {{goal}}
APIs involved: {{apis}}

Provide:
1. The call sequence with auth and pagination handling
2. Retry/backoff and idempotency strategy
3. Data mapping between steps
4. Error handling and logging
5. Pseudocode or a script skeleton''',
      'category': 'Web Automation',
      'subcategory': 'API Automation',
      'tags': 'api, automation, workflow, integration',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'goal::Outcome || apis::Endpoints and auth',
    },
    {
      'title': 'Scheduled Task Designer',
      'description': 'Turn a manual chore into a scheduled job',
      'body': '''Help me automate and schedule a recurring task.

Task: {{task}}
Platform: {{platform}}

Deliver:
1. The script to perform the task
2. The schedule definition (cron or Task Scheduler) with the timing explained
3. Logging and failure notification
4. How to test it runs correctly before trusting it''',
      'category': 'Web Automation',
      'subcategory': 'Task Scheduling',
      'tags': 'cron, scheduling, automation, jobs',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'task::What to automate || platform::Linux cron or Windows Task Scheduler',
    },

    // =====================================================
    // WEB RESEARCH
    // =====================================================
    {
      'title': 'Web Scraper Blueprint',
      'description': 'Plan an ethical, resilient scraper',
      'body': '''Design a scraper for the target below, respecting its terms and robots.txt.

Target data: {{data}}
Source: {{source}}

Provide:
1. Whether an API exists that should be used instead
2. Selector/parse strategy and pagination
3. Rate limiting and polite crawling (delays, caching)
4. Data schema and de-duplication
5. Handling for layout changes and errors
Note any legal/ToS considerations to check first.''',
      'category': 'Web Research',
      'subcategory': 'Web Scraping',
      'tags': 'scraping, parsing, ethics, robots.txt',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'data::What to collect || source::Site/section',
      'rating': 4,
    },
    {
      'title': 'CSS Selector / XPath Helper',
      'description': 'Produce robust selectors for target elements',
      'body': '''Given the HTML snippet and target, give me resilient selectors.

HTML:
```
{{html}}
```
Target: {{target}}

Provide:
1. A CSS selector and an XPath, preferring stable attributes
2. Why brittle selectors (nth-child, generated classes) were avoided
3. A fallback selector
4. How to verify it matches exactly one element''',
      'category': 'Web Research',
      'subcategory': 'CSS Selectors',
      'tags': 'css, xpath, selectors, parsing',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'html::Markup snippet || target::Element to select',
    },
    {
      'title': 'Advanced Search Operators',
      'description': 'Craft precise search-engine queries',
      'body': '''Help me build precise search queries to find: {{goal}}.

Provide several query variations using operators (site:, filetype:, intitle:, quotes, minus, OR, date ranges) and explain what each one narrows down. Then suggest which to try first and how to iterate if results are noisy.''',
      'category': 'Web Research',
      'subcategory': 'Search Operators',
      'tags': 'search, dorking, operators, research',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'goal::What you are trying to find',
      'rating': 4,
    },
    {
      'title': 'Metadata Extraction Plan',
      'description': 'Extract structured metadata from pages',
      'body': '''I need to extract structured metadata from a set of pages.

Fields wanted: {{fields}}
Page type: {{page_type}}

Provide:
1. Where each field usually lives (JSON-LD, OpenGraph, meta tags, DOM)
2. A parsing order that prefers structured data first
3. Normalization rules (dates, currencies, whitespace)
4. Output schema (CSV/JSON) example''',
      'category': 'Web Research',
      'subcategory': 'Metadata Extraction',
      'tags': 'metadata, json-ld, opengraph, extraction',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'fields::Data points to capture || page_type::e.g. product, article',
    },
    {
      'title': 'Public Dataset Finder',
      'description': 'Locate and vet open datasets for a question',
      'body': '''Help me find public datasets to answer: {{question}}.

Provide:
1. Candidate open data sources and portals to check
2. For each, what it likely contains and its license/usage terms
3. Search terms to use on data portals
4. How to assess quality (recency, completeness, methodology)
5. A note on citation and attribution''',
      'category': 'Web Research',
      'subcategory': 'Public Dataset Collection',
      'tags': 'open data, datasets, research, sources',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'question::The question you want data for',
    },

    // =====================================================
    // MEDIA PROCESSING
    // =====================================================
    {
      'title': 'FFmpeg Command Builder',
      'description': 'Generate an exact FFmpeg command for a task',
      'body': '''Build an FFmpeg command for this task and explain each flag.

Task: {{task}}
Input: {{input}}
Target: {{target}}

Provide:
1. The full command, copy-paste ready
2. A short explanation of each flag
3. Quality/size tradeoffs and how to adjust (CRF, bitrate, preset)
4. A variation for batch processing multiple files''',
      'category': 'Media Processing',
      'subcategory': 'FFmpeg',
      'tags': 'ffmpeg, encoding, transcode, cli',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'task::What to do || input::Source format || target::Desired output',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Video Encoding Settings Advisor',
      'description': 'Pick codecs and settings for a use case',
      'body': '''Recommend encoding settings for this use case.

Use case: {{use_case}}
Constraints: {{constraints}}

Cover:
1. Codec choice (H.264/H.265/AV1) and why
2. CRF/bitrate, preset, and resolution guidance
3. Audio codec and bitrate
4. Container choice
5. The tradeoffs between quality, size, and compatibility''',
      'category': 'Media Processing',
      'subcategory': 'Video Encoding',
      'tags': 'encoding, h265, av1, crf, codec',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'use_case::e.g. archival, streaming, mobile || constraints::Size, device, time',
    },
    {
      'title': 'Subtitle Sync & Convert',
      'description': 'Fix and convert subtitle files',
      'body': '''Help me fix subtitles.

Problem: {{problem}}
Formats: {{formats}}

Provide:
1. How to diagnose sync offset or encoding issues
2. FFmpeg or tool commands to shift timing or convert format (SRT/ASS/VTT)
3. How to handle character encoding (UTF-8)
4. How to burn-in vs keep as a soft track''',
      'category': 'Media Processing',
      'subcategory': 'Subtitle Management',
      'tags': 'subtitles, srt, ass, sync, ffmpeg',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'problem::Sync/encoding/format issue || formats::From -> to',
    },
    {
      'title': 'Batch Media Processing Script',
      'description': 'Process a folder of media files',
      'body': '''Write a script to batch-process a folder of media files.

Operation: {{operation}}
Platform: {{platform}}

Requirements:
1. Recurse a directory and match by extension
2. Preserve structure in an output folder
3. Skip already-processed files (idempotent)
4. Parallelism with a safe limit
5. A summary of successes/failures at the end''',
      'category': 'Media Processing',
      'subcategory': 'Batch Processing',
      'tags': 'batch, ffmpeg, script, automation',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'operation::Transcode/resize/etc || platform::bash or PowerShell',
    },
    {
      'title': 'HDR / Tone-Mapping Helper',
      'description': 'Handle HDR to SDR conversion correctly',
      'body': '''Help me convert HDR content correctly.

Goal: {{goal}}
Source: {{source}}

Explain:
1. The color/transfer characteristics involved (PQ/HLG, BT.2020)
2. FFmpeg tone-mapping options for HDR to SDR without washed-out colors
3. How to preserve HDR when remuxing
4. How to verify the result looks correct''',
      'category': 'Media Processing',
      'subcategory': 'HDR',
      'tags': 'hdr, tone mapping, bt2020, ffmpeg',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'goal::Convert/preserve || source::HDR format',
    },

    // =====================================================
    // IPTV & STREAMING
    // =====================================================
    {
      'title': 'M3U Playlist Organizer',
      'description': 'Clean and structure a messy M3U playlist',
      'body': '''You are helping organize a personal IPTV M3U playlist.

Goal: {{goal}}

Provide a plan and the logic to:
1. Parse #EXTINF entries (name, tvg-id, tvg-logo, group-title)
2. Normalize channel names and group-title categories
3. Sort by group then name
4. Flag entries missing tvg-id or logo
5. Output a clean M3U preserving valid attributes
Give a script skeleton to do this.''',
      'category': 'IPTV & Streaming',
      'subcategory': 'M3U Playlist Management',
      'tags': 'm3u, iptv, playlist, organize',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'goal::What clean output you want',
      'rating': 4,
    },
    {
      'title': 'Duplicate Channel Detector',
      'description': 'Find and merge duplicate playlist entries',
      'body': '''Help me detect duplicate channels in an M3U playlist.

Notes: {{notes}}

Provide logic to:
1. Normalize names (case, whitespace, quality tags like HD/FHD)
2. Group likely duplicates by tvg-id and fuzzy name match
3. Choose a preferred entry (by resolution or working URL)
4. Output a de-duplicated playlist plus a report of what was merged
Give a script skeleton.''',
      'category': 'IPTV & Streaming',
      'subcategory': 'Duplicate Detection',
      'tags': 'iptv, duplicates, m3u, dedupe',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'notes::Playlist quirks and preferences',
    },
    {
      'title': 'EPG Mapping Assistant',
      'description': 'Match channels to EPG guide data',
      'body': '''Help me map my channels to EPG (XMLTV) guide data.

Situation: {{situation}}

Provide:
1. How tvg-id links a channel to XMLTV programme data
2. A strategy to match channels missing a tvg-id (name normalization, aliases)
3. How to validate the guide loads and aligns by timezone
4. Troubleshooting for channels showing no guide''',
      'category': 'IPTV & Streaming',
      'subcategory': 'EPG Management',
      'tags': 'epg, xmltv, tvg-id, guide',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'situation::Player, sources, whats missing',
    },
    {
      'title': 'Stream Buffering Diagnosis',
      'description': 'Troubleshoot IPTV buffering issues',
      'body': '''Help me diagnose IPTV buffering.

Symptom: {{symptom}}
Setup: {{setup}}

Walk through:
1. Whether it is source, network, or player side
2. How to test (wired vs wifi, bandwidth, a direct ffplay/VLC test of the URL)
3. Player buffer/cache settings to adjust
4. When transcoding vs direct play is the fix
5. A checklist to isolate the cause''',
      'category': 'IPTV & Streaming',
      'subcategory': 'Buffer Analysis',
      'tags': 'buffering, streaming, troubleshooting, network',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'symptom::When it buffers || setup::Player, device, network',
    },
    {
      'title': 'Jellyfin / Plex Library Setup',
      'description': 'Structure a media library for clean metadata',
      'body': '''Help me structure my media library so {{server}} scrapes metadata cleanly.

Content types: {{content}}

Provide:
1. Folder and file naming conventions for movies and TV
2. How episodes/seasons should be laid out
3. NFO/artwork handling and agents/scrapers
4. Common reasons metadata fails to match and how to fix them
5. A before/after example''',
      'category': 'IPTV & Streaming',
      'subcategory': 'Media Libraries',
      'tags': 'jellyfin, plex, library, metadata, naming',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'server::Jellyfin/Plex/Kodi || content::Movies, TV, music',
      'rating': 4,
    },

    // =====================================================
    // FINANCE & ANALYTICS
    // =====================================================
    {
      'title': 'Personal Budget Builder',
      'description': 'Create a realistic monthly budget framework',
      'body': '''Act as a practical financial coach (not licensed advice). Build a monthly budget framework.

Income: {{income}}
Fixed costs: {{fixed}}
Goals: {{goals}}

Provide:
1. A category breakdown (e.g. 50/30/20 adapted to my numbers)
2. Where to trim if goals are not met
3. An emergency-fund target and timeline
4. A simple tracking method
Note this is educational, not personalized financial advice.''',
      'category': 'Finance & Analytics',
      'subcategory': 'Personal Finance',
      'tags': 'budget, personal finance, planning',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'income::Monthly net || fixed::Rent, bills, debt || goals::Savings targets',
    },
    {
      'title': 'Spreadsheet Formula Architect',
      'description': 'Design formulas for a spreadsheet model',
      'body': '''Help me build spreadsheet formulas.

Goal: {{goal}}
Data layout: {{layout}}
Tool: {{tool}}

Provide:
1. The exact formula(s), with cell references explained
2. An array/dynamic version if it is cleaner
3. Error handling (IFERROR, edge cases)
4. How to make it robust as rows grow''',
      'category': 'Finance & Analytics',
      'subcategory': 'Spreadsheet Models',
      'tags': 'excel, sheets, formulas, modeling',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'goal::What to compute || layout::Columns/sheets || tool::Excel or Google Sheets',
      'rating': 4,
    },
    {
      'title': 'Sports Model Feature Ideas',
      'description': 'Brainstorm features for a sports analytics model',
      'body': '''Act as a sports analytics researcher. For the question below, propose modeling features and an approach.

Question: {{question}}
Available data: {{data}}

Provide:
1. Candidate features and why each has predictive value
2. Data leakage traps to avoid
3. A baseline model and an evaluation metric
4. How to validate honestly (out-of-sample, time-based split)
This is for research/analysis, not gambling advice.''',
      'category': 'Finance & Analytics',
      'subcategory': 'Sports Analytics',
      'tags': 'sports analytics, features, modeling, statistics',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'question::What to predict || data::What you have',
    },
    {
      'title': 'Probability Sanity Check',
      'description': 'Reason through a probability problem carefully',
      'body': '''Work through this probability/statistics problem rigorously.

Problem: {{problem}}

Steps:
1. Define the sample space and assumptions
2. Choose the right approach (conditional, Bayes, distribution) and justify it
3. Show the calculation step by step
4. Give the numeric answer with units/interpretation
5. Note common intuition traps for this type of problem''',
      'category': 'Finance & Analytics',
      'subcategory': 'Probability',
      'tags': 'probability, statistics, bayes, reasoning',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'problem::The problem statement',
    },
    {
      'title': 'Chart / Dashboard Designer',
      'description': 'Choose the right visualization for data',
      'body': '''Help me visualize this data effectively.

Data: {{data}}
Audience & message: {{message}}

Provide:
1. The best chart type(s) for the message and why
2. What to put on each axis / encoding (color, size)
3. What to avoid (dual axes, pie overload, chartjunk)
4. A layout for a small dashboard if multiple views are needed''',
      'category': 'Finance & Analytics',
      'subcategory': 'Data Visualization',
      'tags': 'dataviz, charts, dashboard, design',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'data::What you are plotting || message::The point and audience',
    },

    // =====================================================
    // RESEARCH & KNOWLEDGE
    // =====================================================
    {
      'title': 'Academic Paper Summarizer',
      'description': 'Distill a paper into an actionable summary',
      'body': '''Summarize the paper/text below for a technical reader.

Paper text or abstract:
"""
{{paper}}
"""

Produce:
1. The core contribution in two sentences
2. Method in plain language
3. Key results and their limitations
4. How I could apply or build on this
5. Open questions the paper leaves''',
      'category': 'Research & Knowledge',
      'subcategory': 'Academic Papers',
      'tags': 'research, summary, papers, distillation',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'paper::Abstract or full text',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Literature Review Organizer',
      'description': 'Structure sources into a coherent review',
      'body': '''Help me organize a literature review on: {{topic}}.

Sources / notes: {{sources}}

Provide:
1. A thematic grouping of the sources
2. Points of agreement and disagreement between them
3. Gaps in the current literature
4. An outline for the review with each theme
5. A consistent citation format to use''',
      'category': 'Research & Knowledge',
      'subcategory': 'Citations',
      'tags': 'literature review, synthesis, citations',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Advanced',
      'variables': 'topic::Review subject || sources::List of papers/notes',
    },
    {
      'title': 'Technical Doc Writer',
      'description': 'Draft clear technical documentation',
      'body': '''Write technical documentation for the following.

Subject: {{subject}}
Audience: {{audience}}

Include:
1. A concise overview and when to use it
2. Prerequisites
3. Step-by-step usage with examples
4. Configuration/reference table
5. Troubleshooting and FAQ
Keep it scannable with headings and code blocks.''',
      'category': 'Research & Knowledge',
      'subcategory': 'Technical Documentation',
      'tags': 'documentation, technical writing, reference',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'subject::What to document || audience::Who reads it',
      'rating': 4,
    },
    {
      'title': 'Personal Wiki Structurer',
      'description': 'Design a note structure for a knowledge base',
      'body': '''Help me structure a personal wiki / knowledge base for: {{scope}}.

Provide:
1. A top-level organization scheme (PARA, Zettelkasten, or topic tree) with a recommendation
2. Note templates for the main content types
3. A tagging and linking convention
4. How to keep it maintainable and searchable over time
5. A starter folder/tag list''',
      'category': 'Research & Knowledge',
      'subcategory': 'Personal Wiki',
      'tags': 'wiki, knowledge base, zettelkasten, para',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'scope::What the wiki covers',
    },
    {
      'title': 'OCR Cleanup & Structuring',
      'description': 'Fix and structure raw OCR text',
      'body': '''Clean up this raw OCR output and structure it.

OCR text:
"""
{{ocr}}
"""

Tasks:
1. Fix obvious OCR errors and broken line wraps
2. Restore headings, lists, and tables
3. Flag anything uncertain rather than guessing facts
4. Output clean markdown''',
      'category': 'Research & Knowledge',
      'subcategory': 'OCR',
      'tags': 'ocr, cleanup, markdown, structuring',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'ocr::Raw OCR text',
    },

    // =====================================================
    // KNOWLEDGE MANAGEMENT
    // =====================================================
    {
      'title': 'SOP Generator',
      'description': 'Turn a process into a repeatable SOP',
      'body': '''Create a Standard Operating Procedure for this process.

Process: {{process}}
Owner / audience: {{audience}}

Include:
1. Purpose and scope
2. Roles and prerequisites
3. Numbered steps with decision points
4. Quality checks and definition of done
5. A troubleshooting section and revision date''',
      'category': 'Knowledge Management',
      'subcategory': 'SOPs',
      'tags': 'sop, process, documentation, checklist',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'process::What the SOP covers || audience::Who performs it',
      'rating': 4,
    },
    {
      'title': 'Decision Tree Builder',
      'description': 'Turn a decision into a clear branching guide',
      'body': '''Turn this decision into a clear decision tree.

Decision: {{decision}}
Factors: {{factors}}

Provide:
1. The ordered questions that best split the outcomes
2. A text/indented tree with the recommended action at each leaf
3. Edge cases and defaults
4. A note on when to escalate to a human''',
      'category': 'Knowledge Management',
      'subcategory': 'Decision Trees',
      'tags': 'decision tree, framework, process',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'decision::The decision to model || factors::Inputs that matter',
    },
    {
      'title': 'Cheat Sheet Compiler',
      'description': 'Condense a topic into a one-page reference',
      'body': '''Create a one-page cheat sheet for: {{topic}}.

Constraints: {{constraints}}

Include:
1. The most-used commands/concepts grouped logically
2. Syntax with a tiny example each
3. Gotchas and defaults
4. Keep it dense but scannable with clear sections''',
      'category': 'Knowledge Management',
      'subcategory': 'Cheat Sheets',
      'tags': 'cheat sheet, reference, quick reference',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'topic::Subject || constraints::Focus or level',
      'rating': 4,
    },
    {
      'title': 'Runbook / Playbook Author',
      'description': 'Write an operational playbook for a scenario',
      'body': '''Write an operational playbook for: {{scenario}}.

Provide:
1. Trigger conditions and severity
2. First-responder checklist (first 15 minutes)
3. Step-by-step resolution with commands
4. Escalation path and communication template
5. Post-event review checklist''',
      'category': 'Knowledge Management',
      'subcategory': 'Playbooks',
      'tags': 'playbook, runbook, operations, incident',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'scenario::The situation the playbook handles',
    },
    {
      'title': 'Snippet Library Organizer',
      'description': 'Standardize and tag reusable snippets',
      'body': '''Help me organize a reusable snippet/command library.

Snippets or topics: {{snippets}}

Provide:
1. A naming and tagging convention
2. A standard template (description, code, usage, caveats)
3. Grouping by language/tool
4. How to keep it searchable and avoid duplicates''',
      'category': 'Knowledge Management',
      'subcategory': 'Snippets',
      'tags': 'snippets, organization, templates, reference',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'snippets::What you want to store',
    },

    // =====================================================
    // BUSINESS
    // =====================================================
    {
      'title': 'Brand Voice Definition',
      'description': 'Define a consistent brand voice and tone',
      'body': '''Help me define a brand voice for: {{brand}}.

Audience: {{audience}}
Personality: {{personality}}

Deliver:
1. Three to five voice attributes with do/dont examples
2. Tone shifts by context (support vs marketing)
3. Vocabulary to use and avoid
4. Two before/after rewrites showing the voice applied''',
      'category': 'Business',
      'subcategory': 'Branding',
      'tags': 'branding, voice, tone, marketing',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'brand::What it is || audience::Who it serves || personality::Desired feel',
      'rating': 4,
    },
    {
      'title': 'Marketing Campaign Outline',
      'description': 'Plan a multi-channel campaign',
      'body': '''Outline a marketing campaign.

Product/offer: {{offer}}
Audience: {{audience}}
Budget/constraints: {{constraints}}

Provide:
1. Core message and positioning
2. Channel mix with rationale
3. A content calendar outline
4. Success metrics and how to measure
5. A lean test to validate before scaling''',
      'category': 'Business',
      'subcategory': 'Marketing',
      'tags': 'marketing, campaign, strategy, content',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'offer::What you promote || audience::Target || constraints::Budget/time',
    },
    {
      'title': 'Cold Outreach Rewriter',
      'description': 'Rewrite outreach to be concise and relevant',
      'body': '''Rewrite this outreach message to be respectful, concise, and relevant.

Draft:
"""
{{draft}}
"""
Recipient context: {{context}}

Provide:
1. A tightened version (under 120 words) leading with their value
2. A clear, low-friction call to action
3. A subject line
4. One shorter follow-up
Avoid spammy or manipulative tactics.''',
      'category': 'Business',
      'subcategory': 'Sales',
      'tags': 'sales, outreach, email, copywriting',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'draft::Your message || context::Who they are',
    },
    {
      'title': 'Meeting Notes to Action Items',
      'description': 'Convert messy notes into decisions and tasks',
      'body': '''Turn these meeting notes into a clean summary.

Notes:
"""
{{notes}}
"""

Output:
1. Decisions made
2. Action items with owner and due date (mark TBD if unknown)
3. Open questions
4. A two-sentence summary for people who missed it''',
      'category': 'Business',
      'subcategory': 'Productivity',
      'tags': 'meetings, notes, action items, productivity',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'notes::Raw meeting notes',
      'rating': 4,
    },
    {
      'title': 'Support Reply Drafter',
      'description': 'Draft an empathetic, accurate support reply',
      'body': '''Draft a customer support reply.

Customer message:
"""
{{message}}
"""
Facts / policy: {{facts}}

Provide:
1. An empathetic, clear reply that resolves or sets next steps
2. Only claims supported by the facts given (no guessing)
3. A short version and a detailed version
4. Suggested internal tags/priority''',
      'category': 'Business',
      'subcategory': 'Customer Support',
      'tags': 'support, customer service, email, tone',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'message::Customer text || facts::What is true/allowed',
    },

    // =====================================================
    // CREATIVE
    // =====================================================
    {
      'title': 'Logo Concept Brief',
      'description': 'Generate logo directions from a brief',
      'body': '''Act as a brand designer. Propose logo directions for: {{brand}}.

Values/feel: {{values}}
Constraints: {{constraints}}

Provide:
1. Three distinct concept directions (idea, symbolism, style)
2. Type vs mark vs combination recommendation
3. Color and typography suggestions per direction
4. What to test and how to shortlist
This is a creative brief, not final artwork.''',
      'category': 'Creative',
      'subcategory': 'Logo Design',
      'tags': 'logo, branding, design brief, concepts',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'brand::Name and what it does || values::Personality || constraints::Uses, dont-wants',
    },
    {
      'title': 'UX Flow Critique',
      'description': 'Review a user flow for friction',
      'body': '''Critique this user flow for usability.

Flow: {{flow}}
User goal: {{goal}}

Provide:
1. Friction points and where users likely drop off
2. Cognitive load and clarity issues
3. Concrete improvements ranked by impact/effort
4. Accessibility considerations
5. What to A/B test first''',
      'category': 'Creative',
      'subcategory': 'UI/UX',
      'tags': 'ux, usability, flow, design critique',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'flow::The steps || goal::What the user wants',
      'rating': 4,
    },
    {
      'title': 'Story Premise Developer',
      'description': 'Develop a premise into a story skeleton',
      'body': '''Help me develop this story premise.

Premise: {{premise}}
Tone/genre: {{tone}}

Provide:
1. A sharpened logline
2. The central conflict and stakes
3. Main character want vs need
4. A beat outline (setup, turns, climax, resolution)
5. Three ways to make it less predictable''',
      'category': 'Creative',
      'subcategory': 'Storytelling',
      'tags': 'writing, story, plot, structure',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Intermediate',
      'variables': 'premise::Your idea || tone::Genre and mood',
    },
    {
      'title': 'Writing Editor & Line Polish',
      'description': 'Tighten prose while keeping the voice',
      'body': '''Edit the passage below. Keep my voice; improve clarity and flow.

Passage:
"""
{{passage}}
"""

Provide:
1. A cleaner version
2. A short list of the main changes and why
3. Any unclear sentences flagged as questions
4. Do not add facts I did not write''',
      'category': 'Creative',
      'subcategory': 'Writing',
      'tags': 'editing, writing, prose, clarity',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'passage::Text to edit',
      'rating': 4,
    },
    {
      'title': 'Music Practice Plan',
      'description': 'Build a focused practice routine',
      'body': '''Create a practice plan.

Instrument/skill: {{skill}}
Level & time: {{level}}
Goal: {{goal}}

Provide:
1. A weekly routine broken into warmups, technique, repertoire, and review
2. Specific exercises for the goal
3. How to measure progress
4. How to stay consistent and avoid burnout''',
      'category': 'Creative',
      'subcategory': 'Music',
      'tags': 'music, practice, routine, learning',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'skill::Instrument/area || level::Experience + time || goal::What to achieve',
    },

    // =====================================================
    // PERSONAL ARCHIVE
    // =====================================================
    {
      'title': 'Weekly Review Template',
      'description': 'Run a structured personal weekly review',
      'body': '''Guide me through a weekly review.

Context: {{context}}

Ask me, one section at a time:
1. Wins and what worked
2. What slipped and why
3. Open loops to capture
4. Priorities for next week (max 3)
5. One improvement to try
Then summarize into a clean note I can save.''',
      'category': 'Personal Archive',
      'subcategory': 'Journal',
      'tags': 'weekly review, reflection, productivity, journal',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'context::Whats going on this week',
      'rating': 4,
    },
    {
      'title': 'Learning Roadmap Builder',
      'description': 'Turn a learning goal into a staged plan',
      'body': '''Build a learning roadmap for: {{goal}}.

Current level: {{level}}
Time available: {{time}}

Provide:
1. Milestones from beginner to competent
2. For each milestone: what to learn, a resource type, and a small project to prove it
3. How to test understanding at each stage
4. Common dead-ends to avoid''',
      'category': 'Personal Archive',
      'subcategory': 'Learning',
      'tags': 'learning, roadmap, skill, plan',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'goal::What to learn || level::Starting point || time::Hours per week',
      'rating': 4,
    },
    {
      'title': 'Idea Capture Expander',
      'description': 'Develop a raw idea into a next step',
      'body': '''Help me develop this raw idea.

Idea: {{idea}}

Provide:
1. A one-line restatement of the core idea
2. Why it might matter and who it helps
3. The riskiest assumption to test
4. The smallest next action to move it forward
5. Related ideas or prior art to check''',
      'category': 'Personal Archive',
      'subcategory': 'Ideas',
      'tags': 'ideas, brainstorming, next action',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'idea::The raw idea',
    },
    {
      'title': 'Life Hack Evaluator',
      'description': 'Sanity-check a life hack before adopting it',
      'body': '''Evaluate this life hack / tip before I adopt it.

Hack: {{hack}}

Provide:
1. Whether it actually holds up (evidence or plausibility)
2. Hidden downsides or risks
3. Who it works for and who it does not
4. A simple way to trial it for a week
5. A better alternative if it is weak''',
      'category': 'Personal Archive',
      'subcategory': 'Life Hacks',
      'tags': 'life hacks, evaluation, habits',
      'ai_models': 'Claude, ChatGPT',
      'difficulty': 'Beginner',
      'variables': 'hack::The tip to evaluate',
    },

    // =====================================================
    // IMAGE GENERATION (SFW)
    // =====================================================
    {
      'title': 'Photorealistic Portrait Prompt',
      'description': 'Build a detailed photorealistic portrait prompt',
      'body': '''Create a detailed image-generation prompt for a photorealistic portrait.

Subject: {{subject}}
Mood: {{mood}}

Compose the prompt with:
1. Subject and expression
2. Lighting (e.g. soft window light, golden hour, Rembrandt)
3. Lens and camera feel (e.g. 85mm f/1.8, shallow depth of field)
4. Composition and background
5. Color palette and overall mood
Output a single ready-to-use prompt plus a short suggested negative prompt.''',
      'category': 'Image Generation',
      'subcategory': 'Portraits',
      'tags': 'portrait, photorealism, lighting, prompt',
      'ai_models': 'Midjourney, SDXL, Flux, DALL-E',
      'difficulty': 'Intermediate',
      'variables': 'subject::Who/what || mood::Feeling to convey',
      'rating': 5,
      'is_favorite': 1,
    },
    {
      'title': 'Cinematic Scene Prompt',
      'description': 'Compose a film-still style image prompt',
      'body': '''Write an image prompt for a cinematic film still.

Scene: {{scene}}
Genre/reference: {{genre}}

Include:
1. Subject and action in the frame
2. Cinematic lighting and atmosphere
3. Lens, aspect ratio, and film grain feel
4. Color grade (e.g. teal-orange, muted)
5. Composition (rule of thirds, leading lines)
Return one polished prompt and a matching negative prompt.''',
      'category': 'Image Generation',
      'subcategory': 'Cinematic',
      'tags': 'cinematic, film still, lighting, color grade',
      'ai_models': 'Midjourney, SDXL, Flux',
      'difficulty': 'Intermediate',
      'variables': 'scene::What happens || genre::Look to emulate',
      'rating': 4,
    },
    {
      'title': 'Product Photography Prompt',
      'description': 'Studio-quality product shot prompt',
      'body': '''Create an image prompt for a clean product shot.

Product: {{product}}
Vibe: {{vibe}}

Specify:
1. Surface/background and props (minimal)
2. Studio lighting setup (softbox, rim light, reflections)
3. Angle and framing
4. Material/texture emphasis
5. Color palette
Output one prompt suitable for e-commerce plus a negative prompt.''',
      'category': 'Image Generation',
      'subcategory': 'Product Photography',
      'tags': 'product, studio, ecommerce, lighting',
      'ai_models': 'Midjourney, SDXL, Flux',
      'difficulty': 'Intermediate',
      'variables': 'product::The item || vibe::Premium, playful, etc',
    },
    {
      'title': 'Negative Prompt Toolkit',
      'description': 'Build a reusable negative prompt',
      'body': '''Help me craft a strong negative prompt for {{model}}.

Subject type: {{subject}}
Recurring problems: {{problems}}

Provide:
1. A general-purpose negative prompt for this subject type
2. Additions targeting the specific artifacts I listed
3. A short explanation of why each term helps
4. A note on not over-stacking negatives''',
      'category': 'Image Generation',
      'subcategory': 'Negative Prompts',
      'tags': 'negative prompt, quality, artifacts',
      'ai_models': 'SDXL, Flux, Midjourney',
      'difficulty': 'Intermediate',
      'variables': 'model::Target model || subject::What you generate || problems::Artifacts to fix',
    },
    {
      'title': 'Prompt Optimizer (Image)',
      'description': 'Refine a rough image prompt into a strong one',
      'body': '''Improve my rough image prompt for {{model}}.

Rough prompt:
"""
{{prompt}}
"""

Provide:
1. A rewritten prompt with clear subject, style, lighting, and composition
2. Suggested parameters (aspect ratio, stylize, steps/CFG as relevant)
3. A negative prompt
4. Two variations for different looks''',
      'category': 'Image Generation',
      'subcategory': 'Prompt Optimization',
      'tags': 'prompt optimization, image, refine',
      'ai_models': 'Midjourney, SDXL, Flux',
      'difficulty': 'Intermediate',
      'variables': 'model::Target model || prompt::Your draft',
      'rating': 4,
    },

    // =====================================================
    // VIDEO GENERATION (SFW)
    // =====================================================
    {
      'title': 'Cinematic Video Shot Prompt',
      'description': 'Describe a single cinematic video shot',
      'body': '''Write a text-to-video prompt for one cinematic shot.

Scene: {{scene}}
Duration/feel: {{feel}}

Include:
1. Subject and action
2. Camera movement (e.g. slow dolly-in, orbit, handheld)
3. Lens and framing
4. Lighting and time of day
5. Mood and color
Keep it a single coherent shot; return one ready prompt.''',
      'category': 'Video Generation',
      'subcategory': 'Cinematic Video',
      'tags': 'text-to-video, cinematic, camera motion',
      'ai_models': 'Runway, Kling, Veo, Sora',
      'difficulty': 'Intermediate',
      'variables': 'scene::What happens || feel::Length and mood',
      'rating': 4,
    },
    {
      'title': 'Camera Motion Designer',
      'description': 'Choose camera moves for a video prompt',
      'body': '''Suggest camera movement for this shot and write the prompt language for it.

Shot intent: {{intent}}

Provide:
1. The best camera move(s) to serve the intent and why
2. The exact phrasing to describe the move in a video prompt
3. How to keep motion smooth and avoid warping
4. A fallback if the model struggles with the move''',
      'category': 'Video Generation',
      'subcategory': 'Camera Motion',
      'tags': 'camera motion, video, cinematography',
      'ai_models': 'Runway, Kling, Veo',
      'difficulty': 'Intermediate',
      'variables': 'intent::What the shot should convey',
    },
    {
      'title': 'Character Consistency Across Shots',
      'description': 'Keep a character consistent in generated video',
      'body': '''Help me keep a character consistent across multiple generated shots.

Character description: {{character}}
Tooling: {{tooling}}

Provide:
1. A locked character description block to reuse verbatim
2. Which anchor details to always repeat (face, wardrobe, palette)
3. How to use reference images / seeds if supported
4. Shot-by-shot prompt scaffolding that keeps continuity''',
      'category': 'Video Generation',
      'subcategory': 'Character Consistency',
      'tags': 'consistency, character, video, continuity',
      'ai_models': 'Runway, Kling, Veo',
      'difficulty': 'Advanced',
      'variables': 'character::Who they are || tooling::Model/features available',
    },
    {
      'title': 'Storyboard to Prompts',
      'description': 'Convert a storyboard into shot prompts',
      'body': '''Turn this storyboard/outline into a sequence of video prompts.

Storyboard: {{storyboard}}
Style: {{style}}

For each shot provide:
1. A self-contained prompt (subject, action, camera, lighting)
2. Continuity notes linking it to adjacent shots
3. Suggested duration
Keep a consistent style across all shots.''',
      'category': 'Video Generation',
      'subcategory': 'Storyboards',
      'tags': 'storyboard, sequence, video, prompts',
      'ai_models': 'Runway, Kling, Veo, Sora',
      'difficulty': 'Advanced',
      'variables': 'storyboard::Beats/scenes || style::Consistent look',
    },
  ];
}
