DRUPAL_STABLE=8.9
DRUPAL_DEV=9.0
DRUPAL_TEST=
RELEASE=3.x-dev

TPL=tpl

define prepare
	@echo "Prepare $(1) from ${TPL} for release $(1)..."
	@rm -rf ./$(1)/;
	@cp -r ./${TPL}/ ./$(1)/;
	@RELEASE="$(RELEASE)" IMAGE_TAG="$(1)" envsubst < "./$(TPL)/Dockerfile" > "./$(1)/Dockerfile";
	@echo "...Done!"
endef

prepare:
	$(call prepare,${DRUPAL_STABLE})
	$(call prepare,${DRUPAL_DEV})
ifeq "${DRUPAL_TEST}" ""
	@echo "[[ Skipping test ]]"
else
	$(call prepare,${DRUPAL_TEST})
endif

.PHONY: prepare
