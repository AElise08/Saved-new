# Saved: a Plow Chat agent that archives ideas to a local vault or Notion and
# texts three this-week picks every Sunday. Runs on the Plow OpenClaw base.
#
# Pinned by digest: a moving tag would substitute unreviewed code under a live
# credential. This is base-771198a9 of plow-pbc/plow-openclaw-agent.
FROM public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-771198a9609dcef54d44843e7da5329c17fa51b4@sha256:f1e7c421b97a80f1bd17015f96daceb965f350a241f7edc7e4d856a0e3a6f8f5

# Cloud deployments run the image without compose.yml. Keep the reporting
# identity in the image so every installation reports to the Saved listing.
ENV AGENT_ID=saved
# The scripts keep their vault under HERMES_HOME (the name predates the port);
# point it into the base's persistent state volume.
ENV HERMES_HOME=/var/lib/plow/saved

USER root
COPY LICENSE NOTICE /usr/share/doc/saved/
# Saved's persona goes after the base prompt, so the base's Plow chat rules stay.
COPY runtime/SOUL.md /tmp/SOUL.md
RUN printf '\n' >> /opt/plow/prompt/AGENTS.md \
 && cat /tmp/SOUL.md >> /opt/plow/prompt/AGENTS.md && rm /tmp/SOUL.md
COPY skills/saved/ /opt/plow/skills/saved/

# Root-owned scripts: the drain and every turn run this copy, which the agent
# cannot rewrite.
COPY scripts/ /opt/saved/scripts/
COPY templates/ /opt/saved/templates/
COPY --chmod=0755 image/start.sh /opt/saved/start.sh
RUN chmod -R a+rX /opt/saved /opt/plow/skills/saved && chmod 0755 /opt/saved/scripts/*.py
USER node
CMD ["/opt/saved/start.sh"]
