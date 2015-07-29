RAILS_ENV = test
BUNDLE = RAILS_ENV=${RAILS_ENV} bundle
BUNDLE_OPTIONS = -j 2
RSPEC = rspec
APPRAISAL = appraisal

all: test

test: bundler/install appraisal/install
	${BUNDLE} exec ${APPRAISAL} ${RSPEC} spec 2>&1

bundler/install:
	if ! gem list bundler -i > /dev/null; then \
	  gem install bundler; \
	fi
	${BUNDLE} install ${BUNDLE_OPTIONS}

appraisal/install:
	${BUNDLE} exec ${APPRAISAL} install