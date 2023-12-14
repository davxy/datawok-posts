+++
title = "BeeOS code static analysis"
date = "2018-04-06"
tags = ["os-dev","programming","security"]
+++

BeeOS is a FOSS UNIX-like operating system focused on simplicity and POSIX
compliance.

The overall system is composed by four subprojects:

- The C standard library (`libc`)
- A utility user-space library (`libu`)
- Some user space applications (`user`)
- The kernel (`kernel`)

This analysis targets the BeeOS `kernel` component

[https://github.com/davxy/beeos](https://github.com/davxy/beeos)

The kernel, as most non legacy software, is a "moving target". Thus, to avoid
chasing the codebase with our analysis, we’ve decided to freeze the branch
we’re going to analyze at the version `0.1.1` regardless of the evolution of the
kernel features during the time taken by the process.

Obviously during the analysis period there can be small changes within the
kernel code, but only refactory and fix to get a better compliance with the
guidelines.

In the end, any modification that will benefit to the kernel project will be
integrated into the upstream kernel codebase (`master` branch).

## Analysis Scope

The scope of the analysis is to verify compliance with respect to coding rules
from different standards and tools, to analyze differences, and eventually apply
corrections on the analyzed code.

In particular, the BeeOS sources will be inspected with respect to the following
coding rules:

- MISRA C 2012
- MISRA C 2004
- SEI CERT C

Very briefly, the MISRA rules, are a set of coding guidelines that are applied
especially in the context of safety critical embedded systems.

The CERT C focus more on prevention of security vulnerabilities like
stack-integer and buffer overflows

The two rules families, when followed together, can provide real rock solid
code.

The whole analysis and refactory process is synthesized by the following figure

![audit-proc](/companions/beeos/audit-proc.png)

As evidenced, the process final product will be BeeOS `v0.2.0`.

For every coding standard we will provide a compliance matrix, that is a table
where for each rule the violations are counted to give a quantitative result.

For each coding standard matrix the pre-intervention column refers to the
violations found with the previous phase output; the post-intervetion column is
produced using the output of the whole process (kernel v.0.2.0).

The choice to don’t take as the post-intervention values the output of the
specific phase is due to the fact that some violations that are still present
in a phase output may be resolved (or introduced) as a side effect of some
refactory required by a coding standard that follows in the chain. Thus, to
give a better idea of the overall work result, we’ve decided to provide a
matrix containing the output of the process viewed as a single functional
block.


## References

- Analysis full document [download](/companions/beeos/beeos-static.pdf)
- Project sources @ [github](https://github.com/davxy/beeos)
