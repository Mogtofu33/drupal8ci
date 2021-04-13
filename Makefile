DRUPAL_STABLE=8.9
DRUPAL_DEV=9.0
DRUPAL_TEST=9.1
RELEASE=3.x-dev

TPL=tpl/common
TPL_9_1=tpl/9.1

define prepare
	@echo "Prepare $(1) from ${TPL} for release $(1)..."
	@rm -rf ./$(1)/;
	@cp -r ./${TPL}/ ./$(1)/;
	@RELEASE="$(RELEASE)" IMAGE_TAG="$(1)" envsubst < "./$(TPL)/Dockerfile" > "./$(1)/Dockerfile";
	@RELEASE="$(RELEASE)" IMAGE_TAG="$(1)" envsubst < "./$(TPL)/composer.json" > "./$(1)/composer.json";
	@echo "...Done!"
endef

define fix_9_1
	@echo "Fix $(1) from ${TPL_9_1} for release $(1)..."
	@cp -r ./${TPL_9_1}/* ./$(1)/;
	@RELEASE="$(RELEASE)" IMAGE_TAG="$(1)" envsubst < "./$(TPL_9_1)/Dockerfile" > "./$(1)/Dockerfile";
	@RELEASE="$(RELEASE)" IMAGE_TAG="$(1)" envsubst < "./$(TPL_9_1)/composer.json" > "./$(1)/composer.json";
	@echo "...Done!"
endef

prepare:
	$(call prepare,${DRUPAL_STABLE})
	$(call prepare,${DRUPAL_DEV})
ifeq "${DRUPAL_TEST}" ""
	@echo "[[ Skipping test ]]"
else
	$(call prepare,${DRUPAL_TEST})
	$(call fix_9_1,${DRUPAL_TEST})
endif

.PHONY: prepare
