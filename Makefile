.PHONY: clean clean-spec sources spec

PROJECT    ?= ovsdbapp
PACKAGE    := python-$(PROJECT)
VERSION     = $(shell rpm -q --qf "%{version}\n" --specfile $(PACKAGE).spec | head -1)
RELEASE     = $(shell rpm -q --qf "%{release}\n" --specfile $(PACKAGE).spec | head -1)

GIT        := $(shell which git)

ifdef GIT
HEAD_SHA := $(shell git rev-parse --short --verify HEAD)
TAG      := $(shell git show-ref --tags -d | grep $(HEAD_SHA) | \
                    git name-rev --tags --name-only $$(awk '{print $2}'))
endif

BUILDID := %{nil}
ifndef TAG
BUILDID := .$(shell date --date="$$(git show -s --format=%ci $(HEAD_SHA))" '+%Y%m%d%H%M').git$(HEAD_SHA)
endif

spec: ## create spec file
	@git cat-file -p $(HEAD_SHA):$(PACKAGE).spec | sed -e 's,@BUILDID@,$(BUILDID),g' > $(PACKAGE).spec

sources: ## archive sources
sources: clean spec
	@git archive --format=tar --prefix=$(PROJECT)-$(VERSION)/ $(HEAD_SHA) | \
	     gzip > $(PROJECT)-$(VERSION).tar.gz

ifdef GIT
clean-spec:
	@git checkout $(PACKAGE).spec
endif

clean: ## clean build files
clean: clean-spec
	@rm -rf build srpms rpms $(PROJECT).egg-info $(PROJECT)-*.tar.gz *.egg
