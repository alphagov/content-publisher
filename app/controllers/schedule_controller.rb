class ScheduleController < ApplicationController
  def new
    result = Schedule::NewInteractor.call(params:, user: current_user)
    @edition = result.edition

    if result.publish_issues
      redirect_to document_path(@edition.document), tried_to_publish: true
    elsif result.schedule_issues
      redirect_to document_path(@edition.document)
    end
  end

  def edit
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:scheduled?)
  end

  def update
    result = Schedule::UpdateInteractor.call(params:, user: current_user)
    edition, issues, api_error = result.to_h.values_at(:edition, :issues, :api_error)

    if issues
      flash.now["requirements"] = {
        "items" => issues.items(
          link_options: {
            schedule_date: { href: "#date" },
            schedule_time: { href: "#time" },
          },
        ),
      }

      render :edit,
             assigns: { edition:, issues: },
             status: :unprocessable_entity
    elsif api_error
      redirect_to document_path(edition.document),
                  alert_with_description: t("documents.show.flashes.schedule_error")
    else
      redirect_to document_path(edition.document)
    end
  end

  def create
    result = Schedule::CreateInteractor.call(params:, user: current_user)
    edition, issues, api_error = result.to_h.values_at(:edition, :issues, :api_error)

    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :new,
             assigns: { issues:, edition: },
             status: :unprocessable_entity
    elsif api_error
      redirect_to document_path(edition.document),
                  alert_with_description: t("documents.show.flashes.schedule_error")
    else
      redirect_to scheduled_path(edition.document)
    end
  end

  def destroy
    result = Schedule::DestroyInteractor.call(params:, user: current_user)

    if result.api_error
      redirect_to document_path(params[:document]),
                  alert_with_description: t("documents.show.flashes.unschedule_error")
    else
      redirect_to document_path(params[:document])
    end
  end

  def scheduled
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, &:scheduled?)
  end
end
