## Job Board Smart Contract

A decentralized **Job Board** built with the [Clarity](https://docs.stacks.co/docs/clarity) smart contract language for the [Stacks blockchain](https://www.stacks.co/).  
This contract allows employers to post jobs with STX rewards, workers to apply, and employers to approve and pay workers when jobs are completed.


 ## Features
-  **Post Jobs** — Employers can post jobs with a title and STX reward.  
-  **Apply for Jobs** — Workers can apply to open jobs.  
- **Accept Workers** — Employers choose a worker for the job.  
-  **Complete Jobs & Pay** — Employers mark jobs as completed and automatically transfer rewards to the worker.  
-  **Error Handling**:
  - Prevents unauthorized actions (only employers can accept/complete jobs).
  - Blocks duplicate job applications.
  - Ensures jobs cannot be completed multiple times.

## Contract Structure
- `jobs` — Stores job details (employer, title, reward, worker, status).  
- `applications` — Tracks which workers have applied for which jobs.  
- `job-counter` — Keeps a count of total jobs posted.  

## Public Functions
| Function | Description |
|----------|-------------|
| `post-job (title reward)` | Post a new job with a title and STX reward. |
| `apply-job (job-id)` | Apply for a specific job. |
| `accept-worker (job-id worker)` | Employer accepts a worker for a job. |
| `complete-job (job-id)` | Employer marks the job as complete and transfers STX reward. |

## Read-Only Functions
| Function | Description |
|----------|-------------|
| `get-job (job-id)` | Fetch details of a specific job. |
| `get-application (job-id applicant)` | Check if a worker has applied for a job. |

---

##Error Codes
| Error | Code | Meaning |
|-------|------|---------|
| `ERR_NOT_AUTHORIZED` | `u100` | Caller is not authorized for this action. |
| `ERR_JOB_NOT_FOUND` | `u101` | Job ID does not exist. |
| `ERR_ALREADY_APPLIED` | `u102` | Worker already applied for this job. |
| `ERR_ALREADY_COMPLETED` | `u103` | Job already marked as completed. |
| `ERR_NOT_APPLIED` | `u104` | No worker assigned/applied. |

## Deployment & Testing

 Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed locally.

 Run Tests
```bash
clarinet test
